FactoryGirl.define do
  factory :link do
    sequence(:source_content_id) { |i| "source-#{i}" }
    sequence(:target_content_id) { |i| "target-#{i}" }
    link_type "organisations"
  end
end
