RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class.instance }

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
