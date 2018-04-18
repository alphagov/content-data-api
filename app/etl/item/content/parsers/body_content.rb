class Item::Content::Parsers::BodyContent
  def parse(json)
    json.dig("details", "body")
  end

  def schemas
    %w[
    answer
    case_study
    consultation
    corporate_information_page
    detailed_guide
    document_collection
    fatality_notice
    help_page
    hmrc_manual_section
    html_publication
    manual
    manual_section
    news_article
    publication
    service_manual_guide
    simple_smart_answer
    specialist_document
    speech
    statistical_data_set
    take_part
    topical_event_about_page
    working_group
    world_location_news_article
  ]
  end
end
