module Api
  class KeywordsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
      keywords = Keyword.pluck(:word)

      render json: { keywords: keywords }, status: :ok
    end

    def create
      keyword = Keyword.new(keyword_params)
    
      if keyword.save
        ProcessKeywordJob.perform_later(keyword.id)

        sleep(2)
        group_stats = results_groups

        render json: { message: 'Palavra Chave criada com sucesso!', keyword: keyword, group_stats: group_stats }, status: :created
      else
        render json: { error: "Palavra chave já cadastrada." }, status: :unprocessable_entity
      end
    end

    def update
      keyword = Keyword.find(params[:id])
    
      if keyword.update(keyword_params)
        ProcessKeywordJob.perform_later(keyword.id)

        sleep(2)
        group_stats = results_groups

        render json: { message: 'Palavra Chave atualizada com sucesso!', keyword: keyword, group_stats: group_stats }, status: :created
      else
        render json: { error: "Palavra chave já cadastrada." }, status: :unprocessable_entity
      end
    end

    def destroy
      keyword = Keyword.find(params[:id])
      keyword.destroy

      ProcessKeywordJob.perform_later("")

      sleep(2)
      group_stats = results_groups

      render json: { message: 'Palavra Chave apagada com sucesso!', group_stats: group_stats }, status: :created
    end

    private

    def keyword_params
      params.require(:keyword).permit(:word)
    end

    def results_groups
      group_stats = Analysis.all.map(&:stats)
      words = group_stats.map { |b| b&.values || 0 }.sum()

      status = {
        users_analyzed: Analysis.count,
        mean: Analysis.mean(words),
        median: Analysis.median(words),
        std_dev: Analysis.std_dev(words)
      }

      sleep(2)
      status
    end
  end
end
