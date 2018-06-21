RSpec.describe Item::Content::Parser do
  subject { described_class.instance }

  it "returns content json if schema is 'licence'" do
    json = { schema_name: 'licence',
      details: { licence_overview: 'licence expired' } }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq('licence expired')
  end

  it "returns licence_overview for content provided as array for each content type" do
    json = { schema_name: 'licence',
      details: { licence_overview:
        [
          {
            "content_type": "text/govspeak",
            "content": "licence expired one"
          },
          {
            "content_type": "text/html",
            "content": "licence expired two"
          },
        ] } }

    expect(subject.extract_content(json.deep_stringify_keys)).to eq('licence expired two')
  end
end
