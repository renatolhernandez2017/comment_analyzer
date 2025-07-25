class ProcessUserCommentsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)

    user.comments.each do |comment|
      ProcessSingleCommentJob.perform_later(comment.id)
    end

    RecalculateMetricsJob.perform_later(user.id)
  end
end
