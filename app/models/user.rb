class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :comments, through: :posts
  has_one :analysis, dependent: :destroy

  validates :username, presence: true
end
