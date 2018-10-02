FactoryBot.define do
  factory :facts_edition, class: Facts::Edition do
    dimensions_date
    pdf_count { 0 }
    doc_count { 0 }
    sentences { 0 }
    words { 0 }
    chars { 0 }
    readability { 0 }
  end
end
