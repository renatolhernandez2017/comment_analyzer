class KeywordsController < ApplicationController
  before_action :set_users, only: %i[create update]

  def index
    @keywords = Keyword.all.order(created_at: :desc)
    @keyword = Keyword.new
  end

  def create
    @keyword = Keyword.new(keyword_params)
    
    if @keyword.save
      ProcessKeywordJob.perform_later(@keyword.id)
      redirect_to results_groups_path
    else
      redirect_to keywords_path
    end
  end

  def update
    @keyword = Keyword.find(params[:id])

    if @keyword.update(keyword_params)
      ProcessKeywordJob.perform_later(@keyword.id)
      redirect_to results_groups_path
    else
      redirect_to keywords_path
    end
  end

  def show
    group_stats = Analysis.all.map(&:stats)
    words = group_stats.map { |b| b&.values || 0 }.sum()

    render json: {
      group_stats: {
        users_analyzed: Analysis.count,
        mean: Analysis.mean(words),
        median: Analysis.median(words),
        std_dev: Analysis.std_dev(words)
      }
    }
  end

  def destroy
    @keyword = Keyword.find(params[:id])
    @keyword.destroy

    ProcessKeywordJob.perform_later("")
    redirect_to results_groups_path
  end

  private

  def keyword_params
    params.require(:keyword).permit(:word)
  end

  def set_users
    @users = User.pluck(:id)
  end
end
