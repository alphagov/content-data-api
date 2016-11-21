require 'rails_helper'

describe ContentItem do
  let(:content_item) do
    build(:content_item, organisation_id: 1)
  end

  subject { content_item }

  it "has a content_id attribute" do
    expect(subject.content_id).to eq("fdur5845-fu54-fd86-gy75-5fjdkjfjkfe3-1")
  end

  it "belongs to an organisation" do
    expect(subject).to belong_to(:organisation)
  end

  context "import from Search API" do
    it "imports content items" do
      create(:organisation, slug: "hm-revenue-customs")
      VCR.use_cassette("import_content_items", record: :new_episodes) do
        ContentItem.import
      end
      content_item = ContentItem.first.as_json
      expect(content_item).to have_key("content_id")
    end
  end
end
