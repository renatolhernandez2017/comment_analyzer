class Comment < ApplicationRecord
  include AASM

  belongs_to :post

  validates :body, :email, :name, presence: true

  aasm column: 'status' do
    state :new, initial: true
    state :processing
    state :approved
    state :rejected

    event :start_processing do
      transitions from: [:new, :approved, :rejected], to: :processing
    end

    event :approve do
      transitions from: :processing, to: :approved
    end

    event :reject do
      transitions from: :processing, to: :rejected
    end
  end

  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
end
