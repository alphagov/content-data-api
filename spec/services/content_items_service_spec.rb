RSpec.describe ContentItemsService do
  let(:client) { double('client') }

  before do
    subject.client = client
  end

  describe "#content_ids" do
    it "returns an array of content_ids from the client" do
      allow(subject.client).to receive(:content_ids).and_return(%w(id-123 id-456))
      expect(subject.content_ids).to eq(%w(id-123 id-456))
    end
  end

  describe "#fetch" do
    it "returns a new content item object" do
      allow(subject.client).to receive(:fetch).with("id-123").and_return(
        content_id: "id-123",
        title: "title",
        description: "description",
      )

      content_item = subject.fetch("id-123")
      expect(content_item).to be_a(ContentItem)

      expect(content_item.content_id).to eq("id-123")
      expect(content_item.title).to eq("title")
      expect(content_item.description).to eq("description")
    end
  end

  describe "#links" do
    it "returns an array of link objects" do
      allow(subject.client).to receive(:links).with("id-123").and_return(
        organisations: ["id-456", "id-789"],
        policies: ["id-111"],
      )

      links = subject.links("id-123")
      expect(links.size).to eq(3)

      links.each do |link|
        expect(link).to be_a(Link)
        expect(link.source_content_id).to eq("id-123")
      end

      expect(links[0].link_type).to eq("organisations")
      expect(links[0].target_content_id).to eq("id-456")

      expect(links[1].link_type).to eq("organisations")
      expect(links[1].target_content_id).to eq("id-789")

      expect(links[2].link_type).to eq("policies")
      expect(links[2].target_content_id).to eq("id-111")
    end
  end
end
