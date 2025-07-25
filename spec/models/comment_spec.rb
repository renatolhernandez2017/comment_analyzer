require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:comment) { build(:comment) }

  describe "validações" do
    it "é válido com atributos válidos" do
      expect(comment).to be_valid
    end

    it "não é válido sem corpo" do
      comment.body = nil
      expect(comment).not_to be_valid
    end

    it "não é válido sem nome" do
      comment.name = nil
      expect(comment).not_to be_valid
    end

    it "não é válido sem email" do
      comment.email = nil
      expect(comment).not_to be_valid
    end
  end

  describe "máquina de estados (AASM)" do
    it "inicia com status :new" do
      expect(comment.status).to eq("new")
    end

    it "transita de :new para :processing" do
      comment.start_processing
      expect(comment.status).to eq("processing")
    end

    it "transita de :processing para :approved" do
      comment.start_processing
      comment.approve
      expect(comment.status).to eq("approved")
    end

    it "transita de :processing para :rejected" do
      comment.start_processing
      comment.reject
      expect(comment.status).to eq("rejected")
    end
  end
end
