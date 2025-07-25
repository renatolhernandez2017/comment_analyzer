require 'rails_helper'

RSpec.describe Keyword, type: :model do
  let(:keyword) { build(:keyword) }

  it 'é válido com um word único' do
    expect(keyword).to be_valid
  end

  it 'não é válido sem word' do
    keyword.word = nil
    expect(keyword).not_to be_valid
  end

  it 'não é válido com word duplicado' do
    keyword.save!
    duplicate = build(:keyword, word: keyword.word)
    expect(duplicate).not_to be_valid
  end
end
