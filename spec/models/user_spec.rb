require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  it "é válido com atributos válidos" do
    expect(user).to be_valid
  end

  it "não é válido sem username" do
    user.username = nil
    expect(user).not_to be_valid
  end

  it "deve destruir posts associados ao ser destruído" do
    user.save!
    user.posts.create!(title: "Post 1", body: "Conteúdo do post")
    expect { user.destroy }.to change { Post.count }.by(-1)
  end
end
