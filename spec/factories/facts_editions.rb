FactoryBot.define do
  factory :facts_edition, class: Facts::Edition do
    dimensions_date
    number_of_pdfs 0
  end
end
