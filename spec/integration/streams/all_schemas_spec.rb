require "govuk_message_queue_consumer/test_helpers"

RSpec.describe "Process all schemas" do
  let(:subject) { Streams::Consumer.new }

  SchemasIterator.each_schema do |schema_name, schema|
    %w{major minor links republish unpublish}.each do |update_type|
      it "handles event for: `#{schema_name}` with no errors for a `#{update_type}` update" do
        expect(GovukError).not_to receive(:notify)

        payload = SchemasIterator.payload_for(schema_name, schema)
        message = build(:message, payload: payload, routing_key: "#{schema_name}.#{update_type}")

        subject.process(message)
      end
    end
  end

  it "knows how to parse all GOV.UK schemas" do
    expect(known_schemas).to include(*GovukSchemas::Schema.schema_names)
  end

private

  def known_schemas
    %w[
      answer
      calendar
      case_study
      coming_soon
      completed_transaction
      consultation
      contact
      corporate_information_page
      detailed_guide
      document_collection
      email_alert_signup
      external_content
      facet
      facet_group
      facet_value
      fatality_notice
      finder
      finder_email_signup
      generic
      generic_with_external_related_links
      gone
      government
      guide
      help_page
      hmrc_manual
      hmrc_manual_section
      homepage
      html_publication
      knowledge_alpha
      licence
      local_transaction
      mainstream_browse_page
      manual
      manual_section
      need
      news_article
      organisation
      organisations_homepage
      person
      place
      placeholder
      publication
      redirect
      role
      role_appointment
      service_manual_guide
      service_manual_homepage
      service_manual_service_standard
      service_manual_service_toolkit
      service_manual_topic
      service_sign_in
      simple_smart_answer
      special_route
      specialist_document
      speech
      statistical_data_set
      statistics_announcement
      step_by_step_nav
      take_part
      taxon
      topic
      topical_event_about_page
      transaction
      travel_advice
      travel_advice_index
      unpublishing
      vanish
      working_group
      world_location
      world_location_news_article
    ]
  end
end
