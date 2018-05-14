RSpec.describe Item::Content::Parser do
  subject { described_class.instance }

  describe "#extract_content" do
    context "when valid schema" do
      it "returns content json if schema_name is 'local_transaction'" do
        json = { schema_name: "local_transaction",
          details: { introduction: "Greetings", need_to_know: "A Name",
            more_information: "An Address" } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("Greetings A Name An Address")
      end

      describe "ServiceManualTopic" do
        it "returns description if json does not have 'groups' key" do
          json = { schema_name: "service_manual_topic",
            description: "Blogs",
            details: {} }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq("Blogs")
        end

        it "returns content json" do
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
      end

      it "returns content json if schema_name is 'unpublishing'" do
        json = { schema_name: "unpublishing",
          details: { explanation: "This content has been removed" } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("This content has been removed")
      end

      it "returns content json if schema_name is 'statistics_announcement'" do
        json = { schema_name: "statistics_announcement",
          description: "Announcement",
          details: { display_date: "25 December 2017", state: "closed" } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("Announcement 25 December 2017 closed")
      end

      describe "Taxon" do
        it "returns description if json does not have any child_taxons" do
          json = { schema_name: "taxon",
            description: "Blogs",
            links: {} }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq("Blogs")
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
      end

      describe "ServiceManualStandard" do
        it "returns title and body if json does not have 'children' key" do
          json = {
            schema_name: 'service_manual_service_standard',
            title: 'sm title',
            details: { body: 'the main body' },
            links: {}
          }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq('sm title the main body')
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
      end

      describe "ServiceManualServiceToolkit" do
        it "returns nil if json does not have 'collection' key" do
          json = {
            schema_name: 'service_manual_service_toolkit',
            details: {}
          }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq(nil)
        end

        it "returns 'title' and 'description' if json does not have 'links' key" do
          json = {
            schema_name: 'service_manual_service_toolkit',
            details: {
              collections: [
                {
                  title: 'main title 1',
                  description: 'main desc 1'
                }
              ]
            }
          }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq('main title 1 main desc 1')
        end

        it "returns json content" do
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
      end

      describe "Contact" do
        it "does not return phone numbers if there is no 'phone_numbers' key" do
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
              more_info_post_address: '<p>more info post</p>'
            }
          }
          expected = [
            'main desc title 1 desc 1 title 2 desc 2',
            'more info',
            'post1 title post1 desc post2 title post2 desc',
            'more info post'
          ].join(' ')
          expect(subject.extract_content(json.deep_stringify_keys)).to eq(expected)
        end

        it "does not return post_addresses if there is no 'post_addresses' key" do
          json = {
            schema_name: 'contact',
            details: {
              description: 'main desc',
              email_addresses: [
                { title: 'title 1', description: '<p>desc 1</p>' },
                { title: 'title 2', description: '<p>desc 2</p>' }
              ],
              more_info_email_address: '<p>more info</p>',
              more_info_post_address: '<p>more info post</p>'
            }
          }
          expected = [
            'main desc title 1 desc 1 title 2 desc 2',
            'more info',
            'more info post'
          ].join(' ')
          expect(subject.extract_content(json.deep_stringify_keys)).to eq(expected)
        end

        it "does not return email_addresses if there is no 'email_addresses' key" do
          json = {
            schema_name: 'contact',
            details: {
              description: 'main desc',
              post_addresses: [
                { title: 'post1 title', description: '<p>post1 desc</p>' },
                { title: 'post2 title', description: '<p>post2 desc</p>' }
              ],
              more_info_post_address: '<p>more info post</p>'
            }
          }
          expected = [
            'main desc',
            'post1 title post1 desc post2 title post2 desc',
            'more info post'
          ].join(' ')
          expect(subject.extract_content(json.deep_stringify_keys)).to eq(expected)
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

      describe "GenericWithLinks" do
        it "returns nil if json does not have 'external_related_links' key" do
          json = { schema_name: "generic_with_external_related_links",
            details: {} }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq(nil)
        end

        it "returns content json if schema_name is 'generic_with_external_related_links'" do
          json = { schema_name: "generic_with_external_related_links",
            details: { external_related_links: [
              { title: "Check your Council Tax band" }
            ] } }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq("Check your Council Tax band")
        end
      end

      describe "TravelAdviceIndex" do
        it "returns nil if json does not have children array" do
          json = { schema_name: "travel_advice_index",
            links: {} }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq(nil)
        end

        it "returns content json" do
          json = { schema_name: "travel_advice_index",
            links: { children: [
              { country: { name: "Portugal" } },
              { country: { name: "Brazil" } }
            ] } }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq("Portugal Brazil")
        end
      end

      it "returns content json if schema_name is 'service_sign_in'" do
        json = { schema_name: "service_sign_in",
          details: {
            choose_sign_in: { title: "Proof",
              options: [
                { text: "Use Gateway", hint_text: "You have a user ID" },
                { text: "Use Verify", hint_text: "You have an account" },
              ] },
            create_new_account: { title: "Create", body: "Click here" }
          } }
        expected = "Proof Use Gateway You have a user ID Use Verify You have an account Create Click here"
        expect(subject.extract_content(json.deep_stringify_keys)).to eq(expected)
      end

      it "returns content json if schema_name is 'hmrc_manual'" do
        json = { schema_name: "hmrc_manual",
          title: "HMRC Manual",
          description: "Manual of items",
          details: {
            child_section_groups: [{
              child_sections: [
                { section_id: "ARG6757", title: "Section 1" },
                { section_id: "THP8972", title: "Section 2" }
              ]
            }, {
              child_sections: [
                { section_id: "UP4591", title: "Section 15" }
                ], title: "Update"
              }]
            } }
        expected = "HMRC Manual Manual of items ARG6757 Section 1 THP8972 Section 2 Update UP4591 Section 15"
        expect(subject.extract_content(json.deep_stringify_keys)).to eql(expected)
      end

      it "returns content json if schema_name is 'finder'" do
        json = { schema_name: "finder", title: "Contact HMRC",
          links: { children: [
            { title: "Personal Tax", description: "Email, write or phone us" },
            { title: "Child Benefit", description: "Tweet us" }
          ] } }
        expected = "Contact HMRC Personal Tax Email, write or phone us Child Benefit Tweet us"
        expect(subject.extract_content(json.deep_stringify_keys)).to eql(expected)
      end

      it "returns content json if schema_name is 'mainstream_browse_page'" do
        json = { schema_name: "mainstream_browse_page", title: "Travel Abroad",
          description: "Go abroad",
          links: { children: [
            { title: "Driving Abroad" },
            { title: "Forced Marriage" }
            ],
            related_topics: [
              { title: "Pets" },
              { title: "Help" }
              ] } }
        expected = "Travel Abroad Go abroad Driving Abroad Forced Marriage Pets Help"
        expect(subject.extract_content(json.deep_stringify_keys)).to eql(expected)
      end

      it "returns content json if schema_name is 'service_manual_homepage'" do
        json = { schema_name: "service_manual_homepage", title: "Service Manual",
          description: "Digital Service Standard",
          links: { children: [
            { title: "Design", description: "Naming your service" },
            { title: "Technology", description: "Security and Maintenance" }
            ] } }

        expected = "Service Manual Digital Service Standard Design Naming your service Technology Security and Maintenance"
        expect(subject.extract_content(json.deep_stringify_keys)).to eql(expected)
      end

      it "returns content json if schema_name is 'step_by_step_nav'" do
        json = { schema_name: "step_by_step_nav", details: { step_by_step_nav: {
          title: "Learn to drive a car: step by step", introduction: "It's easy",
          steps: [{ title: "Step 1",
            contents: [{ text: "Enter vehicle" }, contents: [{ text: "A" }, { text: "B" }, { text: "C" }]] },
                  { title: "Step 2",
              contents: [{ text: "Adjust seat" }, contents: [{ text: "Z" }, { text: "Y" }, { text: "X" }]] }]
          } } }

        expected = "Learn to drive a car: step by step It's easy Step 1 Enter vehicle A B C Step 2 Adjust seat Z Y X"
        expect(subject.extract_content(json.deep_stringify_keys)).to eql(expected)
      end
    end

    context "when invalid schema" do
      describe "has no schema_name and no base_path" do
        it "raises an InvalidSchemaError and returns nil" do
          subject.extract_content document_type: 'answer'
          expect(GovukError).to receive(:notify).with(InvalidSchemaError.new("Schema does not exist: "), extra: { base_path: "" })
          expect(subject.extract_content(document_type: 'answer')).to be_nil
        end
      end

      describe "has an unknown schema_name but no base_path" do
        it "logs InvalidSchemaError with the schema_name" do
          json = { schema_name: "blah", links: {} }

          expect(GovukError).to receive(:notify).with(InvalidSchemaError.new("Schema does not exist: blah"), extra: { base_path: "" })

          result = subject.extract_content(json.deep_stringify_keys)
          expect(result).to be_nil
        end
      end

      describe "has an unknown schema_name and a base_path" do
        it "raises InvalidSchemaError with the schema and the base_path" do
          json = { base_path: "/unknown/base_path", schema_name: "unknown",
            links: {} }
          subject.extract_content(json.deep_stringify_keys)
          expect(GovukError).to receive(:notify).with(InvalidSchemaError.new("Schema does not exist: unknown"), extra: { base_path: "/unknown/base_path" })
          expect(subject.extract_content(json.deep_stringify_keys)).to be_nil
        end
      end
    end
  end
end
