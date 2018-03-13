class Parsers::BodyContentParser
  def parse(json)
    json.dig("details", "body")
  end
end
schemas_with_body = %w[
    answer
    case_study
    consultation
    corporate_information_page
    detailed_guide
    document_collection
    fatality_notice
    help
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
  ].freeze

schemas_with_body.each do |schema|
  Parsers::ContentExtractors.register(schema, Parsers::BodyContentParser.new)
end
