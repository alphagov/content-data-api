module Etl::Edition::Content::Parsers
  class BodyContent
    def parse(json)
      ContentArray.new.parse(json.dig("details", "body"))
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
end
