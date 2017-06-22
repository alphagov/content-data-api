RSpec.describe Search do
  def node(content_id)
    FactoryGirl.create(:content_item, content_id: content_id)
  end

  def edge(from:, to:, type:)
    FactoryGirl.create(
      :link,
      source_content_id: from,
      target_content_id: to,
      link_type: type,
    )
  end

  before do
    node("id1")
    node("id2")
    node("id3")
    node("org1")
    node("org2")
    node("policy1")

    edge(from: "id1", to: "org1", type: "organisations")
    edge(from: "id2", to: "org2", type: "organisations")
    edge(from: "id3", to: "org1", type: "organisations")
    edge(from: "id2", to: "policy1", type: "policies")
    edge(from: "id3", to: "policy1", type: "policies")
  end

  it "can paginate" do
    subject.per_page = 5
    subject.page = 2
    subject.execute
    results = subject.content_items

    expect(results.total_pages).to eq(2)
    expect(results.count).to eq(1)
  end

  context "sorting" do
    it "can sort by page_views_desc" do
      ContentItem.update_all(six_months_page_views: 100)
      ContentItem.find_by!(content_id: "id1").update!(six_months_page_views: 999)
      ContentItem.find_by!(content_id: "id3").update!(six_months_page_views: 0)

      subject.sort = :page_views_desc
      subject.per_page = 100
      subject.execute

      results = subject.content_items
      views = results.pluck(:six_months_page_views)

      expect(views).to eq [999, 100, 100, 100, 100, 0]
    end
  end

  let(:content_ids) do
    subject.execute
    subject.content_items.map(&:content_id)
  end

  it "can filter by a single type and single target" do
    subject.filter_by(link_type: "organisations", target_ids: "org1")
    expect(content_ids).to match_array %w(id1 id3)
  end

  it "can filter by a single type and multiple targets" do
    subject.filter_by(link_type: "organisations", target_ids: %w(org1 org2))
    expect(content_ids).to eq %w(id1 id2 id3)
  end

  it "can filter by multiple types for a single target" do
    subject.filter_by(link_type: "organisations", target_ids: "org1")
    subject.filter_by(link_type: "policies", target_ids: "policy1")

    expect(content_ids).to eq %w(id3)
  end

  it "can filter by multiple types and multiple targets" do
    subject.filter_by(link_type: "organisations", target_ids: %w(org1 org2))
    subject.filter_by(link_type: "policies", target_ids: "policy1")

    expect(content_ids).to eq %w(id2 id3)
  end

  it "can filter by source instead of target" do
    subject.filter_by(link_type: "organisations", source_ids: "id2")
    expect(content_ids).to eq %w(org2)
  end

  it "returns no results if there is no target for the type" do
    subject.filter_by(link_type: "policies", target_ids: "org1")
    expect(content_ids).to be_empty
  end

  it "can filter by audit status" do
    content_item = ContentItem.find_by!(content_id: "id2")
    FactoryGirl.create(:audit, content_item: content_item)

    subject.audit_status = :audited
    expect(content_ids).to eq %w(id2)
  end

  it "can filter by passing status" do
    content_item = ContentItem.find_by!(content_id: "id2")
    audit = FactoryGirl.create(:audit, content_item: content_item)
    FactoryGirl.create(
      :response,
      question: FactoryGirl.create(:boolean_question),
      audit: audit,
      value: "yes"
    )

    subject.passing = true
    expect(content_ids).to eq %w(id2)
  end

  it "can filter by not passing status" do
    content_item = ContentItem.find_by!(content_id: "id2")
    audit = FactoryGirl.create(:audit, content_item: content_item)
    FactoryGirl.create(
      :response,
      question: FactoryGirl.create(:boolean_question),
      audit: audit,
      value: "no"
    )

    subject.passing = false
    expect(content_ids).to eq %w{id2}
  end

  it "can filter by document type" do
    content_item = ContentItem.find_by!(content_id: "id2")
    content_item.update!(document_type: "travel_advice")

    subject.document_type = "travel_advice"
    expect(content_ids).to eq %w(id2)
  end

  it "can return an unpaginated scope of content items" do
    subject.per_page = 2
    subject.execute

    expect(subject.content_items.size).to eq(2)
    expect(subject.unpaginated.size).to eq(6)
  end

  describe "#dimension" do
    before do
      content_item = ContentItem.find_by!(content_id: "id2")
      FactoryGirl.create(:audit, content_item: content_item)
    end

    it "applies the block associated with the dimension" do
      audited = subject.dimension(:audited)
      content_ids = audited.content_items.map(&:content_id)
      expect(content_ids).to eq %w(id2)
    end

    it "inherits query parameters" do
      subject.page = 2

      audited = subject.dimension(:audited)
      expect(audited.page).to eq(2)
    end

    it "returns no results if contradictory dimensions are set" do
      search = subject
        .dimension(:audited)
        .dimension(:not_audited)


      content_ids = search.content_items.map(&:content_id)
      expect(content_ids).to be_empty
    end

    it "does not mutate the existing Search" do
      subject.dimension(:audited)
      expect(content_ids).to eq %w(id1 id2 id3 org1 org2 policy1)
    end

    it "memoizes for each dimension" do
      expect(Search::Executor).to receive(:execute).twice

      subject.dimension(:audited)
      subject.dimension(:not_audited)
      subject.dimension(:audited)
    end
  end
end
