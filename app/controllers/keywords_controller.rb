class KeywordsController < ApplicationController
  def index
    @keywords = Keyword.all.order(created_at: :desc)
    @keyword = Keyword.new
  end

  def create
    @keyword = Keyword.new(keyword_params)

    if @keyword.save
      flash[:success] = "Conta Corrente criada com sucesso!"
    end

    redirect_to keywords_path
  end

  def update
    @keyword = Keyword.find(params[:id])

    if @keyword.update(keyword_params)
      flash[:success] = "Palavra Chave atualizada com sucesso."
    end

    redirect_to keywords_path
  end

  def destroy
    @keyword = Keyword.find(params[:id])
    @keyword.destroy

    flash[:success] = "Palavra Chave apagada com sucesso."
    redirect_to keywords_path
  end

  private

  def keyword_params
    params.require(:keyword).permit(:word)
  end
end
