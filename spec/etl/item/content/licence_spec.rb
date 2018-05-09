RSpec.describe Item::Content::Parser do
  subject { described_class.instance }

  it "returns content json if schema is 'licence'" do
    json = { schema_name: 'licence',
      details: { licence_overview: 'licence expired' } }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq('licence expired')
  end
end
