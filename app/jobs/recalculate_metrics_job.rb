class RecalculateMetricsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    approved = user.comments.approved.size
    rejected = user.comments.rejected.size
    word_counts = user.comments.pluck(:translated_body).map { |b| b&.split&.size || 0 }

    analysis = {
      mean: word_counts.sum / word_counts.size.to_f,
      median: word_counts.sort[word_counts.size / 2],
      std_dev: Math.sqrt(word_counts.map { |x| (x - word_counts.sum.to_f / word_counts.size) ** 2 }.sum / word_counts.size.to_f)
    }

    Analysis.find_or_create_by!(user: user).update!(
      approved_count: approved,
      rejected_count: rejected,
      stats: analysis
    )

    # RecalculateGroupMetricsJob.perform_later
  end
end
