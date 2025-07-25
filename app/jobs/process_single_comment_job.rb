
class ProcessSingleCommentJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    keywords = Keyword.pluck(:word)
    comment = Comment.find(comment_id)
    comment.start_processing!

    translated = comment.body
    comment.update!(translated_body: translated)

    matches = keywords.select { |word| translated.downcase.include?(word.downcase) }

    if matches.size >= 2
      comment.approve!
    else
      comment.reject!
    end
  end
end
