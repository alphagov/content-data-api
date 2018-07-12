RSpec.describe Etl::Item::Content::Parser do
  subject { described_class.instance }

  describe "Parts" do
    it "returns nil if the json does not have 'parts' key" do
      json = { schema_name: 'guide',
        details: {} }
      expect(subject.extract_content(json.deep_stringify_keys)).to eq(nil)
    end

    it "returns nil if the part slug is not present in the parts hash" do
      json = { schema_name: 'guide',
        details: { parts: [{ slug: 'bar', body: 'bar', title: 'bar' }] } }
      expect(subject.extract_content(json.deep_stringify_keys, subpage_slug: 'foo')).to eq(nil)
    end

    it "returns body text when extracting content for a single part" do
      json = { schema_name: 'guide',
        details: { parts:
          [
            { slug: 'schools',
              title: 'Schools',
              body: 'Local council' },
            { slug: 'appeal',
              title: 'Appeal',
              body: 'No placement' }
          ] } }
      expect(subject.extract_content(json.deep_stringify_keys, subpage_slug: 'schools')).to eq('Local council')
    end
  end
end
