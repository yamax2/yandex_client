FactoryBot.define do
  factory :token do
    token_type { 'Bearer' }
    access_token { 'access_token' }
    expires_in { 31_536_000 }
    refresh_token { 'refresh_token' }

    sequence(:user_id) { |n| "user_#{n.next}" }
  end
end
