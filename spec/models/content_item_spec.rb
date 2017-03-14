require "rails_helper"

RSpec.describe ContentItem, type: :model do
  it { should have_and_belong_to_many(:organisations) }

  it { should have_and_belong_to_many(:taxonomies) }

  describe "#url" do
    it "returns a url to a content item on gov.uk" do
      content_item = build(:content_item, base_path: "/api/content/item/path/1")
      expect(content_item.url).to eq("https://gov.uk/api/content/item/path/1")
    end
  end

  describe "#create_or_update" do
    it "creates a content item if it does not exist" do
      content_item = { content_id: "second_id", taxons: [] }
      organisation = build(:organisation, slug: "the-organisation")
      expect { ContentItem.create_or_update!(content_item, organisation) }.to change { ContentItem.count }.by(1)
    end

    it "updates a content item if it already exists" do
      create(:content_item, content_id: "the_id", title: "the title")
      organisation = build(:organisation, slug: "the-organisation")

      content_item = { content_id: "the_id", title: "a new title", taxons: [] }

      expect { ContentItem.create_or_update!(content_item, organisation) }.to change { ContentItem.count }.by(0)
      expect(ContentItem.find_by(content_id: "the_id").title).to eq("a new title")
    end

    it "creates a content item when the content item has attributes that don't exist on the model" do
      content_item = { content_id: "the_id", extra_attr: "extra", taxons: [] }
      organisation = build(:organisation, slug: "the-organisation")

      expect { ContentItem.create_or_update!(content_item, organisation) }.to change { ContentItem.count }.by(1)
    end

    it "adds the organisation to the content item" do
      content_item = { content_id: "the_id", taxons: [] }
      organisation = build(:organisation, slug: "the-organisation")

      ContentItem.create_or_update!(content_item, organisation)

      organisations = ContentItem.find_by(content_id: "the_id").organisations
      expect(organisations).to eq([organisation])
    end

    it "adds the taxonomies to the content item" do
      create(:taxonomy, content_id: "taxon_1")
      create(:taxonomy, content_id: "taxon_2")
      content_item = { content_id: "the_id", taxons: %w(taxon_1 taxon_2) }
      organisation = build(:organisation, slug: "the-organisation")

      ContentItem.create_or_update!(content_item, organisation)

      taxonomies = ContentItem.find_by(content_id: "the_id").taxonomies
      expect(taxonomies.count).to eq(2)
    end
  end

  describe "#add_organisation" do
    it "adds an organisation to the content item" do
      organisation = build(:organisation, slug: "the-organisation")
      content_item = create(:content_item, content_id: "the_id", title: "the title")

      content_item.add_organisation(organisation)

      expect(content_item.organisations.count).to eq(1)
    end

    it "does not add an organisation that is already associated with the content item" do
      organisation = build(:organisation, slug: "the-organisation")
      content_item = create(:content_item, content_id: "the_id", title: "the title")
      content_item.organisations << organisation

      content_item.add_organisation(organisation)

      expect(content_item.organisations.count).to eq(1)
    end
  end

  describe "#add_taxonomies" do
    it "adds taxonomies to the content item by taxon content_id" do
      content_item = create(:content_item, content_id: "the_id", title: "the title")
      create(:taxonomy, content_id: "taxon_1")
      create(:taxonomy, content_id: "taxon_2")

      content_item.add_taxonomies(%w(taxon_1 taxon_2))

      expect(content_item.taxonomies.count).to eq(2)
    end

    it "does not add taxonomies already associated with the content item" do
      content_item = create(:content_item, content_id: "the_id", title: "the title")
      taxon = create(:taxonomy, content_id: "taxon_1")
      content_item.taxonomies << taxon

      content_item.add_taxonomies(%w(taxon_1))

      expect(content_item.taxonomies.count).to eq(1)
    end
  end
end
