RSpec.describe Item, type: :model do
  describe ".to_param" do
    let!(:content_item) { build(:content_item, content_id: "content-id-1") }

    it "returns the content id" do
      expect(content_item.to_param).to eq("content-id-1")
    end
  end

  describe "#url" do
    it "returns a url to a content item on gov.uk" do
      content_item = build(:content_item, base_path: "/api/content/item/path/1")
      expect(content_item.url).to eq("https://gov.uk/api/content/item/path/1")
    end
  end

  describe "#linked_topics" do
    it "returns the topics linked to the Content Item" do
      item =  create(:content_item)
      topic = create(:content_item)

      create(:link, source: item, target: topic, link_type: "topics")
      expect(item.linked_topics).to eq [topic]
    end
  end

  describe "#guidance?" do
    it "returns true if document type is `guidance`" do
      content_item = build(:content_item, document_type: "guidance")

      expect(content_item.guidance?).to be true
    end

    it "returns false otherwise" do
      content_item = build(:content_item, document_type: "non-guidance")

      expect(content_item.guidance?).to be false
    end
  end

  describe "withdrawn?" do
    it "returns false" do
      content_item = build(:content_item)

      expect(content_item.withdrawn?).to be false
    end
  end

  describe "#whitehall_url" do
    it "returns a URL to the whitehall edit page" do
      content_item = build(
        :content_item,
        publishing_app: "whitehall",
        content_id: "id123",
      )

      expect(content_item.whitehall_url).to eq(
        "#{WHITEHALL}/government/admin/by-content-id/id123"
      )
    end

    it "returns nil if the publishing_app isn't whitehall" do
      content_item = build(:content_item)
      expect(content_item.whitehall_url).to be_nil
    end
  end
end
