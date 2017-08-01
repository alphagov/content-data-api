RSpec.describe ContentItem, type: :model do
  describe "callbacks" do
    subject { build(:content_item) }

    it "precomputes the content_item's report row after saving" do
      expect { subject.save! }.to change(ReportRow, :count).by(1)
      expect { subject.save! }.not_to change(ReportRow, :count)
    end
  end

  describe ".to_param" do
    let!(:content_item) { build(:content_item, content_id: "content-id-1") }

    it "returns the content id" do
      expect(content_item.to_param).to eq("content-id-1")
    end
  end

  describe ".next_item" do
    let!(:content_items) { create_list(:content_item, 5) }

    it "returns the next item given the current item" do
      result = ContentItem.all.next_item(content_items[0])
      expect(result).to eq(content_items[1])

      result = ContentItem.all.next_item(content_items[1])
      expect(result).to eq(content_items[2])

      result = ContentItem.all.next_item(content_items[2])
      expect(result).to eq(content_items[3])

      result = ContentItem.all.next_item(content_items[3])
      expect(result).to eq(content_items[4])
    end

    it "returns nil if there's no next item" do
      result = ContentItem.all.next_item(content_items[4])
      expect(result).to be_nil
    end

    it "returns nil if the current item isn't in the scope" do
      result = ContentItem.offset(1).next_item(ContentItem.first)
      expect(result).to be_nil
    end

    it "is based on the filtered, ordered scope" do
      scope = ContentItem.limit(3).offset(1).order("id desc")

      result = scope.next_item(content_items[3])
      expect(result).to eq(content_items[2])

      result = scope.next_item(content_items[2])
      expect(result).to eq(content_items[1])

      result = scope.next_item(content_items[1])
      expect(result).to be_nil
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
