require 'rails_helper'

RSpec.describe Api::KeywordsController, type: :controller do
  let!(:keyword) { create(:keyword) }

  describe "GET #index" do
    it "retorna a lista de palavras-chave" do
      get :index, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["keywords"]).to include(keyword.word)
    end
  end

  describe "POST #create" do
    context "quando a palavra chave é nova" do
      let(:new_word) { "novo" }

      it "cria a palavra chave e retorna os stats" do
        expect(ProcessKeywordJob).to receive(:perform_later)

        post :create, params: { keyword: { word: new_word } }, as: :json

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Palavra Chave criada com sucesso!")
        expect(json["keyword"]["word"]).to eq(new_word)
        expect(json["group_stats"]).to be_present
      end
    end

    context "quando a palavra chave já existe" do
      it "retorna erro 422" do
        post :create, params: { keyword: { word: keyword.word } }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Palavra chave já cadastrada.")
      end
    end
  end

  describe "PUT #update" do
    context "quando atualiza com sucesso" do
      let(:updated_word) { "atualizado" }

      it "atualiza a palavra chave e retorna os stats" do
        expect(ProcessKeywordJob).to receive(:perform_later).with(keyword.id)

        put :update, params: { id: keyword.id, keyword: { word: updated_word } }, as: :json

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Palavra Chave atualizada com sucesso!")
        expect(json["keyword"]["word"]).to eq(updated_word)
        expect(json["group_stats"]).to be_present
      end
    end

    context "quando falha a atualização (palavra repetida)" do
      let!(:other_keyword) { create(:keyword, word: "duplicada") }

      it "retorna erro 422" do
        put :update, params: { id: keyword.id, keyword: { word: other_keyword.word } }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Palavra chave já cadastrada.")
      end
    end
  end

  describe "DELETE #destroy" do
    it "deleta a palavra chave e retorna os stats" do
      expect(ProcessKeywordJob).to receive(:perform_later).with("")

      delete :destroy, params: { id: keyword.id }, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Palavra Chave apagada com sucesso!")
      expect(json["group_stats"]).to be_present
      expect(Keyword.exists?(keyword.id)).to be_falsey
    end
  end
end
