require 'rails_helper'

RSpec.describe KeywordsController, type: :controller do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  let!(:keyword) { create(:keyword) }

  describe "GET #index" do
    it "carrega todos os keywords e inicializa um novo keyword" do
      get :index
      expect(assigns(:keywords)).to eq(Keyword.all.order(created_at: :desc))
      expect(assigns(:keyword)).to be_a_new(Keyword)
      expect(response).to render_template(:index)
    end
  end

  describe "POST #create" do
    context "com parâmetros válidos" do
      it "cria um novo keyword, enfileira job e redireciona" do
        expect {
          post :create, params: { keyword: { word: "novo" } }
        }.to change(Keyword, :count).by(1)

        expect(response).to redirect_to(results_groups_path)
        expect(ProcessKeywordJob).to have_been_enqueued.with(Keyword.last.id)
      end
    end

    context "com parâmetros inválidos" do
      it "não cria keyword e redireciona para keywords_path" do
        post :create, params: { keyword: { word: "" } }
        expect(response).to redirect_to(keywords_path)
      end
    end
  end

  describe "PATCH #update" do
    context "com parâmetros válidos" do
      it "atualiza o keyword, enfileira job e redireciona" do
        patch :update, params: { id: keyword.id, keyword: { word: "alterado" } }
        expect(keyword.reload.word).to eq("alterado")
        expect(response).to redirect_to(results_groups_path)
        expect(ProcessKeywordJob).to have_been_enqueued.with(keyword.id)
      end
    end

    context "com parâmetros inválidos" do
      it "não atualiza e redireciona para keywords_path" do
        patch :update, params: { id: keyword.id, keyword: { word: "" } }
        expect(keyword.reload.word).not_to eq("")
        expect(response).to redirect_to(keywords_path)
      end
    end
  end

  describe "GET #show" do
    it "retorna json com estatísticas do grupo" do
      get :show, params: { id: keyword.id }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["group_stats"]).to include(
        "users_analyzed",
        "mean",
        "median",
        "std_dev"
      )
    end
  end

  describe "DELETE #destroy" do
    it "remove o keyword, enfileira job e redireciona" do
      expect {
        delete :destroy, params: { id: keyword.id }
      }.to change(Keyword, :count).by(-1)

      expect(response).to redirect_to(results_groups_path)
      expect(ProcessKeywordJob).to have_been_enqueued.with("")
    end
  end
end
