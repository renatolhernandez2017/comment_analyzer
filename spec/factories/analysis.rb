FactoryBot.define do
  factory :analysis do
    user
    stats { { mean: 25.0, median: 15.0, std_dev: 9.25 } }
  end
end
