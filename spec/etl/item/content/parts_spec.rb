RSpec.describe Item::Content::Parser do
  subject { described_class.instance }

  describe "Parts" do
    it "returns nil if 'guide' schema does not have 'parts' key" do
      json = { schema_name: 'guide',
        details: {} }
      expect(subject.extract_content(json.deep_stringify_keys)).to eq(nil)
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

    it "returns nil if 'travel_advice' schema does not have 'parts' key" do
      json = { schema_name: 'travel_advice',
        details: {} }
      expect(subject.extract_content(json.deep_stringify_keys)).to eq(nil)
    end

    it "returns content json if schema_name is 'travel_advice'" do
      json = { schema_name: 'travel_advice',
        details: { parts:
          [
            { title: 'Some',
              body: 'Advice' },
            { title: 'For',
              body: 'Some Travel' }
          ] } }
      expect(subject.extract_content(json.deep_stringify_keys)).to eq('Some Advice For Some Travel')
    end
  end
end
