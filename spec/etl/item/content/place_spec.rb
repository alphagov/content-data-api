RSpec.describe Item::Content::Parser do
  subject { described_class.instance }

  it "returns content json if schema is 'place'" do
    json = { schema_name: 'place',
      details: { introduction: 'Introduction',
        more_information: 'Enter your postcode' } }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq('Introduction Enter your postcode')
  end
end
