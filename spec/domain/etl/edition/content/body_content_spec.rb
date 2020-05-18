RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  let(:valid_types) do
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
    ].freeze
  end

  it "returns content json from :body for all valid formats" do
    valid_types.each do |schema|
      json = build_raw_json(schema_name: schema, body: "<p>Body for #{schema}</p>")
      expect(subject.extract_content(json.deep_stringify_keys)).to eq("Body for #{schema}"), "Incorrect body for schema: '#{schema}'"
    end
  end

  it "returns nil if details.body does NOT exist" do
    valid_schema_json = { schema_name: "answer", details: {} }
    expect(subject.extract_content(valid_schema_json.deep_stringify_keys)).to eq(nil)
  end

  it "returns nil if details.body is an empty string" do
    valid_schema_json = { schema_name: "answer", details: { body: "" } }
    expect(subject.extract_content(valid_schema_json.deep_stringify_keys)).to eq(nil)
  end

  it "returns nil if details.body is an empty array" do
    valid_schema_json = { schema_name: "answer", details: { body: [] } }
    expect(subject.extract_content(valid_schema_json.deep_stringify_keys)).to eq(nil)
  end

  it "returns body for content provided as array for each content type" do
    valid_types.each do |schema|
      body_multi_html_content = {
        schema_name: "answer",
        details: {
          body: [
            {
              "content_type": "text/govspeak",
              "content": "## Wrong body for #{schema}",
            },
            {
              "content_type": "text/html",
              "content": "<h2>Body for #{schema}</h2>",
            },
          ],
        },
      }

      expect(subject.extract_content(body_multi_html_content.deep_stringify_keys)).to eq("Body for #{schema}")
    end
  end

  it "does not fail with unicode characters" do
    json = build_raw_json(
      body: %(\u003cdiv class="govspeak"\u003e\u003cp\u003eLorem ipsum dolor sit amet.),
      schema_name: "case_study",
    )
    expect(subject.extract_content(json.deep_stringify_keys)).to eq("Lorem ipsum dolor sit amet.")
  end

  def build_raw_json(body:, schema_name:)
    {
      schema_name: schema_name,
      details: {
        body: body,
      },
    }
  end
end
