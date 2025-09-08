FactoryBot.define do
  factory :cart, aliases: [:shopping_cart] do
    association :user
    total_price { 0 }
    abandoned { false }
    last_interaction_at { Time.current }
  end
end