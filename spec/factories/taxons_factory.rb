FactoryGirl.define do
  factory :taxon do
    sequence(:content_id) { |index| "content-id-#{index}" }
    sequence(:title) { |index| "title-#{index}" }
  end
end
