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
          json = build_raw_json(schema_name: schema, body: "<p>Body for #{schema}</p>")
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

      it "returns content json if schema_name is 'travel_advice'" do
        json = { schema_name: 'travel_advice',
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

      it "returns content if schema_name is 'service_manual_service_standard'" do
        json = {
          schema_name: 'service_manual_service_standard',
          title: 'sm title',
          details: { body: 'the main body' },
          links: {
            children: [
              { title: 'ch1 title', description: 'ch1 desc' },
              { title: 'ch2 title', description: 'ch2 desc' }
            ]
          }
        }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq('sm title the main body ch1 title ch1 desc ch2 title ch2 desc')
      end

      it "returns content if schema name is 'service_manual_service_toolkit'" do
        json = {
          schema_name: 'service_manual_service_toolkit',
          details: {
            collections: [
              {
                title: 'main title 1',
                description: 'main desc 1',
                links: [
                  { title: 'title link 1', description: 'desc link 1' },
                  { title: 'title link 2', description: 'desc link 2' }
                ]
              }
            ]
          }
        }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq('main title 1 main desc 1 title link 1 desc link 1 title link 2 desc link 2')
      end

      it "returns content if schema name is 'contact'" do
        json = {
          schema_name: 'contact',
          details: {
            description: 'main desc',
            email_addresses: [
              { title: 'title 1', description: '<p>desc 1</p>' },
              { title: 'title 2', description: '<p>desc 2</p>' }
            ],
            more_info_email_address: '<p>more info</p>',
            post_addresses: [
              { title: 'post1 title', description: '<p>post1 desc</p>' },
              { title: 'post2 title', description: '<p>post2 desc</p>' }
            ],
            more_info_post_address: '<p>more info post</p>',
            phone_numbers: [
              { title: 'phone1 title', description: '<p>phone1 desc</p>' },
              { title: 'phone2 title', description: '<p>phone2 desc</p>' }
            ],
            more_info_phone_number: '<p>more info phone</p>'
          }
        }
        expected = [
          'main desc title 1 desc 1 title 2 desc 2',
          'more info',
          'post1 title post1 desc post2 title post2 desc',
          'more info post',
          'phone1 title phone1 desc phone2 title phone2 desc more info phone'
        ].join(' ')
        expect(subject.extract_content(json.deep_stringify_keys)).to eq(expected)
      end

      it "returns content if schema name is 'need'" do
        json = {
          schema_name: 'need',
          details: {
            role: 'the role',
            goal: 'the goal',
            benefit: 'the benefit'
          }
        }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq('the role the goal the benefit')
      end

      it "returns content json if schema_name is 'gone'" do
        json = { schema_name: "gone",
          details: { explanation: "No page here" } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("No page here")
      end

      it "returns content json if schema_name is 'generic_with_external_related_links'" do
        json = { schema_name: "generic_with_external_related_links",
          details: { external_related_links: [
            { title: "Check your Council Tax band" }
          ] } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("Check your Council Tax band")
      end

      it "returns content json if schema_name is 'travel_advice_index'" do
        json = { schema_name: "travel_advice_index",
          links: { children: [
              { country: { name: "Portugal" } },
              { country: { name: "Brazil" } }
            ] } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("Portugal Brazil")
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
