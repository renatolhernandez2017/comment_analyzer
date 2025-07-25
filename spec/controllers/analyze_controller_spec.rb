require 'rails_helper'

RSpec.describe AnalyzeController, type: :controller do
  let!(:user) { create(:user) }
  let!(:analysis) { create(:analysis, user: user) }
  let!(:keyword) { create(:keyword) }

  before do
    allow(Keyword).to receive(:pluck).with(:id, :word).and_return([[keyword.id, keyword.word]])
  end

  describe "GET #index" do
    it "deve carregar todas as análises e keywords" do
      get :index
      expect(assigns(:analysis)).to eq(Analysis.all.order(created_at: :desc))
      expect(assigns(:keywords)).to eq([[keyword.id, keyword.word]])
      expect(response).to render_template(:index)
    end
  end

  describe "POST #create" do
    context "quando usuário existe na API" do
      it "chama ImportUserDataService e redireciona para progress" do
        service = instance_double("ImportUserDataService")
        expect(ImportUserDataService).to receive(:new).with("Renato").and_return(service)
        expect(service).to receive(:call).and_return(user) # retorna o user criado

        post :create, params: { username: "Renato" }
        expect(response).to redirect_to(progress_path(id: user.id))
        expect(flash[:notice]).to eq("Análise iniciada para Renato")
      end
    end
  end

  describe "GET #show" do
    context "quando usuário existe e tem análise" do
      it "retorna json com dados da análise e estatísticas do grupo" do
        post_record = create(:post, user: user)
        create(:comment, post: post_record, name: "A", email: "a@example.com", body: "Comentário", status: "approved")
        create(:comment, post: post_record, name: "B", email: "b@example.com", body: "Comentário 2", status: "rejected")

        get :show, params: { id: user.id }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["user"]).to eq(user.username)
        expect(json["approved"]).to eq(1)
        expect(json["rejected"]).to eq(1)
      end
    end

    context "quando usuário não existe" do
      it "retorna 404 com erro" do
        get :show, params: { id: 1 } # id que não existe
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("User not found")
      end
    end
  end

  describe "GET #progress" do
    it "retorna progresso da análise do usuário em json" do
      post_record = create(:post, user: user)
      create(:comment, post: post_record, name: "A", email: "a@example.com", body: "Comentário", status: "new")
      create(:comment, post: post_record, name: "B", email: "b@example.com", body: "Comentário 2", status: "approved")

      get :progress, params: { id: user.id }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["user"]).to eq(user.username)
      expect(json["total_comments"]).to eq(2)
      expect(json["processed_comments"]).to eq(1)
      expect(json["progress"]).to be_a(String)
    end
  end
end
