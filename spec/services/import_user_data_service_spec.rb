require 'rails_helper'

RSpec.describe ImportUserDataService do
  let(:username) { "Bret" }
  let(:service) { described_class.new(username) }

  let(:user_data) do
    [{
      "id" => 1,
      "username" => "Bret"
    }]
  end

  let(:posts_data) do
    [
      { "id" => 1, "userId" => 1, "title" => "Post 1", "body" => "Body 1" },
      { "id" => 2, "userId" => 1, "title" => "Post 2", "body" => "Body 2" }
    ]
  end

  let(:comments_data) do
    [
      { "id" => 1, "postId" => 1, "name" => "Commenter 1", "email" => "email1@test.com", "body" => "Comment 1" },
      { "id" => 2, "postId" => 1, "name" => "Commenter 2", "email" => "email2@test.com", "body" => "Comment 2" }
    ]
  end

  before do
    # Mock HTTParty calls
    allow(HTTParty).to receive(:get).with("https://jsonplaceholder.typicode.com/users?username=#{username}")
                                      .and_return(double(parsed_response: user_data))
    allow(HTTParty).to receive(:get).with("https://jsonplaceholder.typicode.com/posts?userId=1")
                                      .and_return(double(parsed_response: posts_data))
    allow(HTTParty).to receive(:get).with("https://jsonplaceholder.typicode.com/comments?postId=1")
                                      .and_return(double(parsed_response: comments_data))
    allow(HTTParty).to receive(:get).with("https://jsonplaceholder.typicode.com/comments?postId=2")
                                      .and_return(double(parsed_response: [])) # no comments for post 2

    # Stub the job enqueue
    allow(ProcessUserCommentsJob).to receive(:perform_later)
  end

  describe "#call" do
    context "quando usuário existe na API" do
      it "importa o usuário, posts, comentários e enfileira o job" do
        expect { service.call }.to change(User, :count).by(1)
                              .and change(Post, :count).by(2)
                              .and change(Comment, :count).by(2)

        user = User.find_by(external_id: 1)
        expect(user.username).to eq("Bret")

        post1 = Post.find_by(external_id: 1)
        expect(post1.title).to eq("Post 1")
        expect(post1.body).to eq("Body 1")
        expect(post1.user).to eq(user)

        comment1 = Comment.find_by(external_id: 1)
        expect(comment1.name).to eq("Commenter 1")
        expect(comment1.status).to eq("new")
        expect(comment1.post).to eq(post1)

        expect(ProcessUserCommentsJob).to have_received(:perform_later).with(user.id)
      end
    end

    context "quando usuário não existe na API" do
      before do
        allow(HTTParty).to receive(:get).with("https://jsonplaceholder.typicode.com/users?username=NoUser")
                                          .and_return(double(parsed_response: []))
      end

      it "levanta exceção UserNotFound" do
        service = described_class.new("NoUser")
        expect { service.call }.to raise_error(ImportUserDataService::UserNotFound)
      end
    end
  end
end
