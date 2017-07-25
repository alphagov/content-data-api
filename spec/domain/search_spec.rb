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

      search = Search.new(query)

      results = search.content_items
      views = results.pluck(:six_months_page_views)

      expect(views).to eq [999, 100, 100, 100, 100, 0]
    end

    it "breaks ties on base path" do
      ContentItem.update_all(six_months_page_views: 100)
      ContentItem.find_by!(content_id: "id1").update!(six_months_page_views: 999, base_path: '/b')
      ContentItem.find_by!(content_id: "id2").update!(six_months_page_views: 999, base_path: '/c')
      ContentItem.find_by!(content_id: "id3").update!(six_months_page_views: 999, base_path: '/a')

      query = Search::QueryBuilder.new
        .sort(:page_views_desc)
        .per_page(100)

      search = Search.new(query)

      results = search.content_items

      expect(results[0][:base_path]).to eq('/a')
      expect(results[1][:base_path]).to eq('/b')
      expect(results[2][:base_path]).to eq('/c')
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

    expect(content_ids_for(query)).to match_array %w(id1 id3)
  end

  it "can filter by a single type and multiple targets" do
    query = Search::QueryBuilder.new
      .filter_by(link_type: "organisations", target_ids: %w(org1 org2))

    expect(content_ids_for(query)).to match_array %w(id1 id2 id3)
  end

  it "can filter by multiple types for a single target" do
    query = Search::QueryBuilder.new
      .filter_by(link_type: "organisations", target_ids: "org1")
      .filter_by(link_type: "policies", target_ids: "policy1")

    expect(content_ids_for(query)).to eq %w(id3)
  end

  it "can filter by multiple types and multiple targets" do
    query = Search::QueryBuilder.new
      .filter_by(link_type: "organisations", target_ids: %w(org1 org2))
      .filter_by(link_type: "policies", target_ids: "policy1")

    expect(content_ids_for(query)).to match_array %w(id2 id3)
  end

  it "can filter by source instead of target" do
    query = Search::QueryBuilder.new
      .filter_by(link_type: "organisations", source_ids: "id2")

    expect(content_ids_for(query)).to eq %w(org2)
  end

  it "returns no results if there is no target for the type" do
    query = Search::QueryBuilder.new
      .filter_by(link_type: "policies", target_ids: "org1")

    expect(content_ids_for(query)).to be_empty
  end

  it "can filter by audit status" do
    content_item = ContentItem.find_by!(content_id: "id2")
    create(:audit, content_item: content_item)

    query = Search::QueryBuilder.new.audited

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

    query = Search::QueryBuilder.new.passing

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

    query = Search::QueryBuilder.new.not_passing

    expect(content_ids_for(query)).to eq %w{id2}
  end

  it "can filter by document type" do
    content_item = ContentItem.find_by!(content_id: "id2")
    content_item.update!(document_type: "travel_advice")

    query = Search::QueryBuilder.new
      .document_type('travel_advice')

    expect(content_ids_for(query)).to contain_exactly("id2")
  end

  it "can return an unpaginated scope of content items" do
    query = Search::QueryBuilder.new.per_page(2)

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
      query = Search::QueryBuilder.new.audited

      expect(content_ids_for(query)).to contain_exactly("id2")
    end

    it "returns no results if contradictory audit statuses are set" do
      query = Search::QueryBuilder.new
        .audited
        .non_audited

      expect(content_ids_for(query)).to be_empty
    end
  end

  describe "finding the next item" do
    before do
      ContentItem.update_all(six_months_page_views: 0)
      ContentItem.find_by!(content_id: "id1").update!(six_months_page_views: 100, base_path: '/item-2')
      ContentItem.find_by!(content_id: "id2").update!(six_months_page_views: 100, base_path: '/item-1')
      ContentItem.find_by!(content_id: "id3").update!(six_months_page_views: 50)

      @all_items = Search.new.content_items
      expect(@all_items[0][:content_id]).to eq('id2')
      expect(@all_items[1][:content_id]).to eq('id1')
      expect(@all_items[2][:content_id]).to eq('id3')
    end

    it "can find the next item with fewer page views" do
      current_item = @all_items[1]
      next_item_query = Search::QueryBuilder.new
        .after(current_item)

      next_items = Search.new(next_item_query).content_items
      expect(next_items[0][:id]).to eq(@all_items[2][:id])
    end

    it "can find the next item with the same page views" do
      current_item = @all_items[0]
      next_item_query = Search::QueryBuilder.new
        .after(current_item)

      next_items = Search.new(next_item_query).content_items
      expect(next_items[0][:id]).to eq(@all_items[1][:id])
    end
  end
end
