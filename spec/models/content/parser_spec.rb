RSpec.describe Content::Parser do
  subject { described_class.instance }

  describe "#extract_content" do
    context "when valid schema" do
      it 'returns content json from :body for all valid formats' do
        valid_types = %w[
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
        valid_types.each do |schema|
          json = build_raw_json(schema_name: schema, body: "Body for #{schema}")
          expect(subject.extract_content(json.deep_stringify_keys)).to eq("Body for #{schema}"), "Incorrect body for schema: '#{schema}'"
        end
      end

      it 'returns nil if details.body does NOT exist' do
        valid_schema_json = { schema_name: 'answer', details: {} }
        expect(subject.extract_content(valid_schema_json.deep_stringify_keys)).to eq(nil)
      end

      it 'does not fail with unicode characters' do
        json = build_raw_json(
          body: %{\u003cdiv class="govspeak"\u003e\u003cp\u003eLorem ipsum dolor sit amet.},
          schema_name: 'case_study'
        )

        expect(subject.extract_content(json.deep_stringify_keys)).to eq('Lorem ipsum dolor sit amet.')
      end

      it "returns content json if schema is 'licence'" do
        json = { schema_name: 'licence',
          details: { licence_overview: 'licence expired' } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq('licence expired')
      end

      it "returns content json if schema is 'place'" do
        json = { schema_name: 'place',
          details: { introduction: 'Introduction',
            more_information: 'Enter your postcode' } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq('Introduction Enter your postcode')
      end

      it "returns content json if schema_name is 'guide'" do
        json = { schema_name: 'guide',
          details: { parts:
            [
              { title: 'Schools',
                body: 'Local council' },
              { title: 'Appeal',
                body: 'No placement' }
            ] } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq('Schools Local council Appeal No placement')
      end

      it "returns content json if schema_name is 'travel_advise'" do
        json = { schema_name: 'travel_advise',
          details: { parts:
            [
              { title: 'Some',
                body: 'Advise' },
              { title: 'For',
                body: 'Some Travel' }
            ] } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq('Some Advise For Some Travel')
      end

      it "returns content json if schema_name is 'transaction'" do
        json = { schema_name: "transaction",
          details: { introductory_paragraph: "Report changes",
            start_button_text: "Start",
            will_continue_on: "Carer's Allowance service",
            more_information: "Facts" } }
        expected = "Report changes Start Carer's Allowance service Facts"
        expect(subject.extract_content(json.deep_stringify_keys)).to eq(expected)
      end

      it "returns content json if schema_name is 'email_alert_signup'" do
        json = { schema_name: "email_alert_signup",
          details: { breadcrumbs: [{ title: "The title" }],
            summary: "Summary" } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("The title Summary")
      end

      it "returns content json if schema_name is 'finder_email_signup'" do
        json = { schema_name: "finder_email_signup",
          description: "Use buttons",
          details: { email_signup_choice:
            [
              { radio_button_name: "Yes" },
              { radio_button_name: "No" }
            ] } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("Yes No Use buttons")
      end

      it "returns content json if schema_name is 'location_transaction'" do
        json = { schema_name: "location_transaction",
          details: { introduction: "Greetings", need_to_know: "A Name",
            more_information: "An Address" } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("Greetings A Name An Address")
      end

      it "returns content json if schema_name is 'service_manual_topic'" do
        json = { schema_name: "service_manual_topic",
          description: "Blogs",
          details: { groups:
            [
              { name: "Design",
                description: "thinking" },
              { name: "Performance",
                description: "analysis" }
            ] } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("Blogs Design thinking Performance analysis")
      end

      it "returns content json if schema_name is 'unpublished'" do
        json = { schema_name: "unpublished",
          details: { explanation: "This content has been removed" } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("This content has been removed")
      end

      it "returns content json if schema_name is 'statistics_announcement'" do
        json = { schema_name: "statistics_announcement",
          description: "Announcement",
          details: { display_date: "25 December 2017", state: "closed" } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("Announcement 25 December 2017 closed")
      end

      it "returns content json if schema_name is 'taxon'" do
        json = { schema_name: "taxon",
          description: "Blogs",
          links: { child_taxons: [
            { title: "One", description: "first" },
            { title: "Two", description: "second" }
          ] } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("Blogs One first Two second")
      end

      def build_raw_json(body:, schema_name:)
        {
          schema_name: schema_name,
          details: {
            body: body
          }
        }
      end
    end

    context 'when invalid schema' do
      it 'raise InvalidSchemaError if json schema_name is not known' do
        no_schema_json = { schema_name: 'blah' }
        expect { subject.extract_content(no_schema_json) }.to raise_error(InvalidSchemaError)
      end

      it 'raises InvalidSchemaError if non-empty json does not have a schema_name' do
        invalid_schema = { document_type: 'answer' }
        expect { subject.extract_content(invalid_schema) }.to raise_error(InvalidSchemaError)
      end
    end
  end
end
