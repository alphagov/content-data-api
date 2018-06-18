FactoryBot.define do
  factory :feedex, class: Events::Feedex do
    sequence(:page_path) { |i| "/path/#{i}" }
    sequence(:date) { |i| i.days.ago.to_date }
    feedex_comments 1
  end
end
