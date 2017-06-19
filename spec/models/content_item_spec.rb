RSpec.describe ContentItem, type: :model do
  describe ".next_item" do
    let!(:content_items) { FactoryGirl.create_list(:content_item, 5) }

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

  describe ".targets_of" do
    let!(:a) { FactoryGirl.create(:content_item) }
    let!(:b) { FactoryGirl.create(:content_item) }
    let!(:c) { FactoryGirl.create(:content_item) }

    before do
      FactoryGirl.create(:link, source: a, target: b, link_type: "type1")
      FactoryGirl.create(:link, source: b, target: a, link_type: "type1")

      FactoryGirl.create(:link, source: a, target: c, link_type: "type2")
      FactoryGirl.create(:link, source: b, target: c, link_type: "type2")
    end

    it "returns a scope of items that have links to them with the given type" do
      results = described_class.targets_of(link_type: "type1")
      expect(results).to match_array [a, b]

      results = described_class.targets_of(link_type: "type2")
      expect(results).to eq [c]

      results = described_class.targets_of(link_type: "type3")
      expect(results).to eq []
    end

    it "selects a count of the number of incoming links" do
      results = described_class.targets_of(link_type: "type1")
      expect(results.map(&:incoming_links_count)).to eq [1, 1]

      results = described_class.targets_of(link_type: "type2")
      expect(results.map(&:incoming_links_count)).to eq [2]
    end

    it "can count incoming links for a subset of content items" do
      subset = described_class.where(id: [a])

      results = described_class.targets_of(link_type: "type1", scope_to_count: subset)
      expect(results.map(&:incoming_links_count)).to match_array [0, 1]

      results = described_class.targets_of(link_type: "type2", scope_to_count: subset)
      expect(results.map(&:incoming_links_count)).to eq [1]
    end

    it "can cope with empty content item scopes" do
      subset = described_class.none
      results = described_class.targets_of(link_type: "anything", scope_to_count: subset)

      expect { results.first }.not_to raise_error
    end
  end

  describe "#title_with_count" do
    before do
      item = FactoryGirl.create(:content_item, title: "Title")
      FactoryGirl.create(:link, source: item, target: item, link_type: "type")
    end

    it "returns the title with the count of incoming links" do
      item = described_class.targets_of(link_type: "type").first
      expect(item.title_with_count).to eq("Title (1)")
    end

    it "returns the title if incoming_links_count isn't set" do
      item = described_class.first
      expect(item.title_with_count).to eq("Title")
    end
  end

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

  describe "#add_taxons_by_id" do
    it "adds taxons to the content item by taxon content_id" do
      content_item = create(:content_item)
      taxons = %w(taxon_1 taxon_2)
      create(:taxon, content_id: "taxon_1")
      create(:taxon, content_id: "taxon_2")

      content_item.add_taxons_by_id(taxons)

      expect(content_item.taxons.count).to eq(2)
    end

    it "does not add taxons already associated with the content item" do
      content_item = create(:content_item)
      taxon = create(:taxon, content_id: "taxon_1")
      content_item.taxons << taxon

      content_item.add_taxons_by_id(%w(taxon_1))

      expect(content_item.taxons.count).to eq(1)
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
        Link.create(link_type: "policy_areas", source_content_id: "cid1", target_content_id: "policy_area_1")

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
