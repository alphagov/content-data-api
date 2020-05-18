class Etl::Edition::Content::Parsers::BodyContent
  def parse(json)
    body = json.dig("details", "body")
    return if body.blank?

    if body.is_a?(Array)
      body_by_content_type = body.map(&:values).to_h
      body = body_by_content_type.fetch("text/html", nil)
    end

    body
  end

  def schemas
    %w[
      answer
      calendar
      case_study
      consultation
      corporate_information_page
      detailed_guide
      document_collection
      fatality_notice
      help_page
      history
      hmrc_manual_section
      html_publication
      manual
      manual_section
      news_article
      organisation
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
