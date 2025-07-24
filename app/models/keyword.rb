class Keyword < ApplicationRecord
  validates :word, presence: true, uniqueness: true

  after_commit :reprocess_all_users

  private

  def reprocess_all_users
    User.find_each do |user|
      ProcessUserCommentsJob.perform_later(user.id)
    end
  end
end
