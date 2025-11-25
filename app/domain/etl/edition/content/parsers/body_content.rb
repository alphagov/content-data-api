class Etl::Edition::Content::Parsers::BodyContent
  def parse(json)
    body = json.dig("details", "body")
    return if body.blank?

    if body.is_a?(Array)
      html_content = body.find { |content_hash| content_hash["content_type"] == "text/html" }
      return if html_content.blank?

      html_content["content"]
    else
      body
    end
  end

  def schemas
    %w[
      answer
      calendar
      call_for_evidence
      case_study
      consultation
      corporate_information_page
      detailed_guide
      document_collection
      fatality_notice
      fields_of_operation
      get_involved
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
      topical_event
      topical_event_about_page
      working_group
      world_location_news
      world_location_news_article
      worldwide_corporate_information_page
      worldwide_office
      worldwide_organisation
    ]
  end
end
