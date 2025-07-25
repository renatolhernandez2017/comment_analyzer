require 'httparty'

class ImportUserDataService
  class UserNotFound < StandardError; end

  def initialize(username)
    @username = username
  end

  def call
    user_data = fetch_user
    raise UserNotFound unless user_data.present?

    user = User.find_or_create_by!(external_id: user_data["id"]) do |u|
      u.username = user_data["username"]
    end

    posts = fetch_posts(user.external_id)

    posts.each do |post_data|
      post = Post.find_or_create_by!(external_id: post_data["id"]) do |p|
        p.user = user
        p.title = post_data["title"]
        p.body = post_data["body"]
      end

      comments = fetch_comments(post.external_id)
      comments.each do |comment_data|
        Comment.find_or_create_by!(external_id: comment_data["id"]) do |c|
          c.post = post
          c.name = comment_data["name"]
          c.email = comment_data["email"]
          c.body = comment_data["body"]
          c.status = 'new'
        end
      end
    end

    ProcessUserCommentsJob.perform_later(user.id)
  end

  private

  def fetch_user
    HTTParty.get("https://jsonplaceholder.typicode.com/users?username=#{@username}").parsed_response.first
  end

  def fetch_posts(user_id)
    HTTParty.get("https://jsonplaceholder.typicode.com/posts?userId=#{user_id}").parsed_response
  end

  def fetch_comments(post_id)
    HTTParty.get("https://jsonplaceholder.typicode.com/comments?postId=#{post_id}").parsed_response
  end
end
