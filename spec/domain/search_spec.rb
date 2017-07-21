RSpec.describe Search do
  def node(content_id)
    create(:content_item, content_id: content_id)
  end

  def edge(from:, to:, type:)
    create(
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
    query = Search::QueryBuilder.new
      .per_page(5)
      .page(2)
      .build

    search = Search.new(query)
    results = search.content_items

    expect(results.total_pages).to eq(2)
    expect(results.count).to eq(1)
  end

  context "sorting" do
    it "can sort by page_views_desc" do
      ContentItem.update_all(six_months_page_views: 100)
      ContentItem.find_by!(content_id: "id1").update!(six_months_page_views: 999)
      ContentItem.find_by!(content_id: "id3").update!(six_months_page_views: 0)

      query = Search::QueryBuilder.new
        .sort(:page_views_desc)
        .per_page(100)
        .build

      search = Search.new(query)

      results = search.content_items
      views = results.pluck(:six_months_page_views)

      expect(views).to eq [999, 100, 100, 100, 100, 0]
    end
  end

  def content_ids_for(query)
    Search.new(query)
      .content_items
      .map(&:content_id)
  end

  it "can filter by a single type and single target" do
    query = Search::QueryBuilder.new
      .filter_by(link_type: "organisations", target_ids: "org1")
      .build
    expect(content_ids_for(query)).to match_array %w(id1 id3)
  end

  it "can filter by a single type and multiple targets" do
    query = Search::QueryBuilder.new
      .filter_by(link_type: "organisations", target_ids: %w(org1 org2))
      .build
    expect(content_ids_for(query)).to match_array %w(id1 id2 id3)
  end

  it "can filter by multiple types for a single target" do
    query = Search::QueryBuilder.new
      .filter_by(link_type: "organisations", target_ids: "org1")
      .filter_by(link_type: "policies", target_ids: "policy1")
      .build

    expect(content_ids_for(query)).to eq %w(id3)
  end

  it "can filter by multiple types and multiple targets" do
    query = Search::QueryBuilder.new
      .filter_by(link_type: "organisations", target_ids: %w(org1 org2))
      .filter_by(link_type: "policies", target_ids: "policy1")
      .build

    expect(content_ids_for(query)).to match_array %w(id2 id3)
  end

  it "can filter by source instead of target" do
    query = Search::QueryBuilder.new
      .filter_by(link_type: "organisations", source_ids: "id2")
      .build
    expect(content_ids_for(query)).to eq %w(org2)
  end

  it "returns no results if there is no target for the type" do
    query = Search::QueryBuilder.new
      .filter_by(link_type: "policies", target_ids: "org1")
      .build
    expect(content_ids_for(query)).to be_empty
  end

  it "can filter by audit status" do
    content_item = ContentItem.find_by!(content_id: "id2")
    create(:audit, content_item: content_item)

    query = Search::QueryBuilder.new
      .audited
      .build
    expect(content_ids_for(query)).to eq %w(id2)
  end

  it "can filter by passing status" do
    content_item = ContentItem.find_by!(content_id: "id2")
    audit = create(:audit, content_item: content_item)
    create(
      :response,
      question: create(:boolean_question),
      audit: audit,
      value: "no"
    )

    query = Search::QueryBuilder.new
      .passing
      .build
    expect(content_ids_for(query)).to eq %w(id2)
  end

  it "can filter by not passing status" do
    content_item = ContentItem.find_by!(content_id: "id2")
    audit = create(:audit, content_item: content_item)
    create(
      :response,
      question: create(:boolean_question),
      audit: audit,
      value: "yes"
    )

    query = Search::QueryBuilder.new
      .not_passing
      .build
    expect(content_ids_for(query)).to eq %w{id2}
  end

  it "can filter by document type" do
    content_item = ContentItem.find_by!(content_id: "id2")
    content_item.update!(document_type: "travel_advice")

    query = Search::QueryBuilder.new
      .document_type('travel_advice')
      .build
    expect(content_ids_for(query)).to contain_exactly("id2")
  end

  it "can return an unpaginated scope of content items" do
    query = Search::QueryBuilder.new
      .per_page(2)
      .build
    search = Search.new(query)

    expect(search.content_items.size).to eq(2)
    expect(search.unpaginated.size).to eq(6)
  end

  describe "with an audited content item" do
    before do
      content_item = ContentItem.find_by!(content_id: "id2")
      create(:audit, content_item: content_item)
    end

    it "can search for audited content items" do
      query = Search::QueryBuilder.new
        .audited
        .build

      expect(content_ids_for(query)).to contain_exactly("id2")
    end

    it "returns no results if contradictory audit statuses are set" do
      query = Search::QueryBuilder.new
        .audited
        .non_audited
        .build

      expect(content_ids_for(query)).to be_empty
    end
  end
end
