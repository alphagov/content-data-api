FactoryGirl.define do
  factory :inventory_rule do
    subtheme
    sequence(:link_type) { |i| "link-type-#{i}" }
    sequence(:target_content_id) { |i| "target-content-id-#{i}" }
  end
end
