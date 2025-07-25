require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }
  let(:post) { build(:post, user: user) }

  describe 'validações' do
    it 'é válido com atributos válidos' do
      expect(post).to be_valid
    end

    it 'não é válido sem título' do
      post.title = nil
      expect(post).not_to be_valid
    end

    it 'não é válido sem corpo' do
      post.body = nil
      expect(post).not_to be_valid
    end

    it 'não é válido sem usuário associado' do
      post.user = nil
      expect(post).not_to be_valid
    end
  end

  describe 'associações' do
    it 'pertence a um usuário' do
      expect(post.user).to eq(user)
    end

    it 'tem muitos comentários' do
      expect(post).to respond_to(:comments)
    end
  end
end
