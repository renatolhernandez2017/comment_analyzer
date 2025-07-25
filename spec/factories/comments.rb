FactoryBot.define do
  factory :comment do
    name { "Usuário Teste" }
    email { "user@example.com" }
    body { "Comentário interessante!" }
    post
  end
end
