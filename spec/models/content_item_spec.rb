RSpec.describe ContentItem, type: :model do
  describe "#url" do
    it "returns a url to a content item on gov.uk" do
      content_item = build(:content_item, base_path: "/api/content/item/path/1")
      expect(content_item.url).to eq("https://gov.uk/api/content/item/path/1")
    end
  end

  describe "#add_organisations_by_title" do
    it "adds organisations to the content item" do
      create(:organisation, content_id: "org_1")
      create(:organisation, content_id: "org_2")
      organisations = %w(org_1 org_2)
      content_item = create(:content_item)

      content_item.add_organisations_by_id(organisations)

      expect(content_item.organisations.count).to eq(2)
    end

    it "does not add an organisation that is already associated with the content item" do
      organisation = create(:organisation, content_id: "org_1")
      content_item = create(:content_item)
      content_item.organisations << organisation

      content_item.add_organisations_by_id(%w(org_1))

      expect(content_item.organisations.count).to eq(1)
    end
  end

  describe "#add_taxonomies_by_id" do
    it "adds taxonomies to the content item by taxon content_id" do
      content_item = create(:content_item)
      taxons = %w(taxon_1 taxon_2)
      create(:taxonomy, content_id: "taxon_1")
      create(:taxonomy, content_id: "taxon_2")

      content_item.add_taxonomies_by_id(taxons)

      expect(content_item.taxonomies.count).to eq(2)
    end

    it "does not add taxonomies already associated with the content item" do
      content_item = create(:content_item)
      taxon = create(:taxonomy, content_id: "taxon_1")
      content_item.taxonomies << taxon

      content_item.add_taxonomies_by_id(%w(taxon_1))

      expect(content_item.taxonomies.count).to eq(1)
    end
  end

  describe "linked content" do
    let!(:content_item) { create(:content_item, content_id: "cid1") }

    describe "#topics" do
      it "returns the topics linked to the Content Item" do
        topic = create(:content_item, content_id: "topic1")
        Link.create(link_type: "topics", source_content_id: "cid1", target_content_id: "topic1")

        expect(content_item.topics).to match_array([topic])
      end
    end

    describe "#organisations_tmp" do
      it "returns the topics linked to the Content Item" do
        organisation = create(:content_item, content_id: "org1")
        Link.create(link_type: "organisations", source_content_id: "cid1", target_content_id: "org1")

        expect(content_item.organisations_tmp).to match_array([organisation])
      end
    end

    describe "#policy_areas" do
      it "returns the topics linked to the Content Item" do
        policy_area = create(:content_item, content_id: "policy_area_1")
        Link.create(link_type: "policy-areas", source_content_id: "cid1", target_content_id: "policy_area_1")

        expect(content_item.policy_areas).to match_array([policy_area])
      end
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
end
