FactoryGirl.define do
  factory :taxonomy do
    sequence(:content_id) { |index| "content-id-#{index}" }
    sequence(:title) { |index| "title-#{index}" }
  end
end
