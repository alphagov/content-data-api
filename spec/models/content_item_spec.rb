require "rails_helper"

RSpec.describe ContentItem, type: :model do
  it { should have_and_belong_to_many(:organisations) }

  describe "#url" do
    it "returns a url to a content item on gov.uk" do
      content_item = build(:content_item, base_path: "/api/content/item/path/1")
      expect(content_item.url).to eq("https://gov.uk/api/content/item/path/1")
    end
  end

  describe "#create_or_update" do
    let(:content_item_1) { { content_id: "first_id" } }
    let(:content_item_2) { { content_id: "second_id" } }
    let(:organisation) { build(:organisation, slug: "the-organisation") }

    before do
      create(:content_item, content_id: "first_id", title: "the title")
    end

    it "creates a content item if it does not exist" do
      expect { ContentItem.create_or_update!(content_item_2, organisation) }.to change { ContentItem.count }.by(1)
    end

    it "updates a content item if it already exists" do
      content_item_1[:title] = "a new title"

      expect { ContentItem.create_or_update!(content_item_1, organisation) }.to change { ContentItem.count }.by(0)
      expect(ContentItem.find_by(content_id: "first_id").title).to eq("a new title")
    end

    it "creates a content item when the content item has attributes that don't exist on the model" do
      content_item_with_extra = { content_id: "with_extra", extra: "an extra attribute" }

      expect { ContentItem.create_or_update!(content_item_with_extra, organisation) }.to change { ContentItem.count }.by(1)
    end

    it "adds the organisation to the content item" do
      ContentItem.create_or_update!(content_item_2, organisation)
      organisations = ContentItem.find_by(content_id: "second_id").organisations
      expect(organisations).to eq([organisation])
    end
  end
end
