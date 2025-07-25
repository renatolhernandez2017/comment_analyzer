FactoryBot.define do
  factory :keyword do
    sequence(:word) { |n| "palavra#{n}" }
  end
end
