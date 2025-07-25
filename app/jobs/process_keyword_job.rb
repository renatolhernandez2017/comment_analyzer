class ProcessKeywordJob < ApplicationJob
  queue_as :default

  def perform(keyword_id)
    keyword = Keyword.find(keyword_id) if keyword_id.present?

    User.find_each do |user|
      ProcessUserCommentsJob.perform_now(user.id)
    end

    keyword.update!(processing: false) if keyword_id.present?
  end
end
