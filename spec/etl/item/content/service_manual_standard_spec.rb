RSpec.describe Item::Content::Parser do
  subject { described_class.instance }

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
