RSpec.describe ItemsService do
  let(:client) { double('client') }

  before do
    subject.client = client
  end

  describe "#fetch_all_with_default_locale_only" do
    let(:editions) do
      [
        { content_id: "a", locale: "en" },
        { content_id: "a", locale: "cy" },

        { content_id: "b", locale: "cy" },
        { content_id: "b", locale: "en" },

        { content_id: "c", locale: "cy" },
        { content_id: "c", locale: "cs" },
      ]
    end

    before do
      allow(client).to receive(:fetch_all)
        .with(%w[content_id locale user_facing_version])
        .and_return(editions)
    end

    it "only returns one of each content id" do
      content_ids = subject.fetch_all_with_default_locale_only
        .map { |content_item| content_item[:content_id] }
      expect(content_ids).to contain_exactly("a", "b", "c")
    end

    it "returns 'en' locales where available" do
      expect(subject.fetch_all_with_default_locale_only).to include(
        { content_id: "a", locale: "en" },
        content_id: "b", locale: "en",
      )
    end

    it "returns the first locale if 'en' is not available" do
      expect(subject.fetch_all_with_default_locale_only).to include(
        content_id: "c", locale: "cy"
      )
    end
  end

  describe "#fetch" do
    it "returns a new content item object" do
      allow(subject.client).to receive(:fetch).with("id-123", locale: "en", version: "9").and_return(
        content_id: "id-123",
        title: "title",
        description: "description",
        content_store: "live",
        details: { the: :details },
        publishing_app: "publishing_app",
        locale: "en",
      )

      content_item = subject.fetch("id-123", "en", "9")
      expect(content_item).to be_a(Item)

      expect(content_item.content_id).to eq("id-123")
      expect(content_item.title).to eq("title")
      expect(content_item.description).to eq("description")
      expect(content_item.details).to eq(the: :details)
      expect(content_item.publishing_app).to eq("publishing_app")
      expect(content_item.locale).to eq("en")
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
