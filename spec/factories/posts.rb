FactoryBot.define do
  factory :post do
    title { "Título Exemplo" }
    body { "Conteúdo do post exemplo" }
    association :user
  end
end
