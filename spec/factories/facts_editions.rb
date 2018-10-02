FactoryBot.define do
  factory :facts_edition, class: Facts::Edition do
    dimensions_date
    pdf_count { 0 }
  end
end
