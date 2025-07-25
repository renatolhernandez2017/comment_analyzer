class AnalyzeController < ApplicationController
  before_action :set_keywords

  def index
    @analysis = Analysis.all.order(created_at: :desc)
  end

  def create
    username = params[:username]

    if username.blank?
      redirect_to root_path, alert: "Username obrigatório"
      return
    else
      begin
        ImportUserDataService.new(username).call
        redirect_to progress_path(username: username), notice: "Análise iniciada para #{username}"
      rescue ImportUserDataService::UserNotFound
        redirect_to root_path, alert: "Usuário '#{username}' não encontrado na API"
      end
    end
  end

  def show
    @user = User.find_by(username: params[:username].capitalize)
    return render json: { error: "User not found" }, status: :not_found unless @user

    @analysis = @user.analysis
    return render json: { error: "Analysis not available yet" }, status: :processing unless @analysis

    group_stats = Analysis.all.map(&:stats)
    words = group_stats.map { |b| b&.values || 0 }.sum()

    render json: {
      user: @user.username,
      approved: @user.comments.approved.count,
      rejected: @user.comments.rejected.count,
      stats: @analysis.stats,
      group_stats: {
        users_analyzed: Analysis.count,
        mean: mean(words),
        median: median(words),
        std_dev: std_dev(words)
      }
    }
  end

  def progress
    @user = User.find_by(username: params[:username])
    @total = @user.comments.count
    @processed = @user.comments.where.not(status: 'new').count
    @progress = (@processed.to_f / @total * 100).round(2)

    render json: {
      user: @user.username,
      total_comments: @total,
      processed_comments: @processed,
      progress: "#{(@processed.to_f / @total * 100).round(2)}%"
    }
  end

  private

  def set_keywords
    @keywords = Keyword.pluck(:id, :word)
  end

  def median(arr)
    return 0 if arr.empty? || (arr.first.nil? || arr.last.nil?)

    sorted = arr.sort
    mid = sorted.length / 2
    sorted.length.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0
  end

  def std_dev(arr)
    arr = arr.compact.map(&:to_f)

    return 0 if arr.empty? || (arr.first.nil? || arr.last.nil?)

    m = mean(arr)
    Math.sqrt(arr.map { |x| (x - m)**2 }.sum / arr.size)
  end

  def mean(arr)
    arr = arr.compact.map(&:to_f)

    return 0 if arr.empty? || (arr.first.nil? || arr.last.nil?) || arr.sum <= 0

    arr.sum / arr.size
  end
end
