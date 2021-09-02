RSpec.describe Finders::Content do
  include AggregationsSupport

  let(:primary_org_id) { "96cad973-92dc-41ea-a0ff-c377908fee74" }

  let(:filter) do
    {
      date_range: "past-30-days",
      organisation_id: primary_org_id,
      document_type: nil,
      sort_attribute: nil,
      sort_direction: nil,
    }
  end

  before do
    create :user
  end

  it "returns the aggregations for the past 30 days" do
    edition1 = create :edition, base_path: "/path1", date: 2.months.ago, primary_organisation_id: primary_org_id
    edition2 = create :edition, base_path: "/path2", date: 2.months.ago, primary_organisation_id: primary_org_id

    create :metric, edition: edition1, date: 15.days.ago, upviews: 15, useful_yes: 8, useful_no: 9, searches: 10
    create :metric, edition: edition1, date: 10.days.ago, upviews: 20, useful_yes: 5, useful_no: 1, searches: 1
    create :metric, edition: edition2, date: 10.days.ago, upviews: 15, useful_yes: 8, useful_no: 19, searches: 10
    create :metric, edition: edition2, date: 11.days.ago, upviews: 10, useful_yes: 5, useful_no: 1, searches: 11

    recalculate_aggregations!

    response = described_class.call(filter: filter)
    expect(response[:results]).to contain_exactly(
      hash_including(upviews: 35, searches: 11, satisfaction: 0.565217391304348),
      hash_including(upviews: 25, searches: 21, satisfaction: 0.393939393939394),
    )
  end

  it "returns the metadata for the past 30 days" do
    edition1 = create :edition,
                      base_path: "/path1",
                      primary_organisation_id: primary_org_id,
                      title: "title-01",
                      document_type: "document-type-01"

    edition2 = create :edition,
                      base_path: "/path2",
                      primary_organisation_id: primary_org_id,
                      title: "title-02",
                      document_type: "document-type-02"

    create :metric, edition: edition1, date: 15.days.ago
    create :metric, edition: edition2, date: 10.days.ago

    recalculate_aggregations!

    response = described_class.call(filter: filter)
    expect(response[:results]).to contain_exactly(
      hash_including(base_path: "/path1"),
      hash_including(base_path: "/path2"),
    )
  end

  context "Newly created editions before ETL process" do
    it "returns total_results for editions with facts metrics" do
      edition1 = create :edition, base_path: "/path1", date: 10.days.ago, primary_organisation_id: primary_org_id
      create :edition, base_path: "/path2", date: 10.days.ago, primary_organisation_id: primary_org_id

      create :metric, edition: edition1, date: 10.days.ago, upviews: 15, useful_yes: 8, useful_no: 9, searches: 10

      recalculate_aggregations!

      response = described_class.call(filter: filter)

      expect(response[:total_results]).to eq(1)
    end
  end

  describe "Other date ranges" do
    let(:this_month_date) { Time.zone.today }
    let(:edition1) { create :edition, base_path: "/path1", date: 2.months.ago, primary_organisation_id: primary_org_id }
    let(:edition2) { create :edition, base_path: "/path2", date: 2.months.ago, primary_organisation_id: primary_org_id }

    it "returns aggregations for last month" do
      last_month_date = (Time.zone.today - 1.month)
      create :metric, edition: edition1, date: this_month_date, upviews: 15, useful_yes: 8, useful_no: 9, searches: 10
      create :metric, edition: edition1, date: last_month_date, upviews: 20, useful_yes: 4, useful_no: 1, searches: 1
      create :metric, edition: edition2, date: this_month_date, upviews: 15, useful_yes: 8, useful_no: 19, searches: 10
      create :metric, edition: edition2, date: last_month_date, upviews: 10, useful_yes: 4, useful_no: 1, searches: 11

      recalculate_aggregations!

      response = described_class.call(filter: filter.merge(date_range: "last-month"))

      expect(response[:results]).to contain_exactly(
        hash_including(upviews: 20, searches: 1, satisfaction: 0.8),
        hash_including(upviews: 10, searches: 11, satisfaction: 0.8),
      )
    end

    it "returns aggregations for past 3 months" do
      two_months_ago_date = (Time.zone.today - 2.months)
      create :metric, edition: edition1, date: this_month_date, upviews: 15, useful_yes: 1, useful_no: 4, searches: 10
      create :metric, edition: edition1, date: two_months_ago_date, upviews: 20, useful_yes: 4, useful_no: 1, searches: 1
      create :metric, edition: edition2, date: this_month_date, upviews: 15, useful_yes: 1, useful_no: 4, searches: 10
      create :metric, edition: edition2, date: two_months_ago_date, upviews: 10, useful_yes: 4, useful_no: 1, searches: 11

      recalculate_aggregations!

      response = described_class.call(filter: filter.merge(date_range: "past-3-months"))

      expect(response[:results]).to contain_exactly(
        hash_including(upviews: 35, searches: 11, satisfaction: 0.5),
        hash_including(upviews: 25, searches: 21, satisfaction: 0.5),
      )
    end

    it "returns aggregations for past 6 months" do
      five_months_ago_date = (Time.zone.today - 5.months)
      create :metric, edition: edition1, date: this_month_date, upviews: 15, useful_yes: 1, useful_no: 4, searches: 10
      create :metric, edition: edition1, date: five_months_ago_date, upviews: 20, useful_yes: 4, useful_no: 1, searches: 1
      create :metric, edition: edition2, date: this_month_date, upviews: 15, useful_yes: 1, useful_no: 4, searches: 10
      create :metric, edition: edition2, date: five_months_ago_date, upviews: 10, useful_yes: 4, useful_no: 1, searches: 11

      recalculate_aggregations!

      response = described_class.call(filter: filter.merge(date_range: "past-6-months"))

      expect(response[:results]).to contain_exactly(
        hash_including(upviews: 35, searches: 11, satisfaction: 0.5),
        hash_including(upviews: 25, searches: 21, satisfaction: 0.5),
      )
    end

    it "returns aggregations for past year" do
      eleven_months_ago_date = (Time.zone.today - 11.months)
      create :metric, edition: edition1, date: this_month_date, upviews: 15, useful_yes: 1, useful_no: 4, searches: 10
      create :metric, edition: edition1, date: eleven_months_ago_date, upviews: 20, useful_yes: 4, useful_no: 1, searches: 1
      create :metric, edition: edition2, date: this_month_date, upviews: 15, useful_yes: 1, useful_no: 4, searches: 10
      create :metric, edition: edition2, date: eleven_months_ago_date, upviews: 10, useful_yes: 4, useful_no: 1, searches: 11

      recalculate_aggregations!

      response = described_class.call(filter: filter.merge(date_range: "past-year"))

      expect(response[:results]).to contain_exactly(
        hash_including(upviews: 35, searches: 11, satisfaction: 0.5),
        hash_including(upviews: 25, searches: 21, satisfaction: 0.5),
      )
    end

    it "returns aggregations for a specific month" do
      august2021 = Date.new(2021, 8, 1)
      create :metric, edition: edition1, date: this_month_date, upviews: 15, useful_yes: 1, useful_no: 4, searches: 10
      create :metric, edition: edition1, date: august2021, upviews: 20, useful_yes: 4, useful_no: 1, searches: 1
      create :metric, edition: edition2, date: august2021, upviews: 10, useful_yes: 4, useful_no: 1, searches: 11

      recalculate_aggregations!

      response = described_class.call(filter: filter.merge(date_range: "august-2021"))

      expect(response[:results]).to contain_exactly(
        hash_including(upviews: 20, searches: 1, satisfaction: 0.8),
        hash_including(upviews: 10, searches: 11, satisfaction: 0.8),
      )
    end
  end

  describe "Filter by all document types" do
    it "doesnt include document_type in the query" do
      scope = described_class
                .new(filter.merge(document_type: "all"))
                .send(:apply_filter)

      expect(scope.to_sql).not_to include("document_type")
    end
  end

  describe "Filter by all organisations" do
    let(:edition1) { create :edition, date: 15.days.ago }
    let(:edition2) { create :edition, date: 15.days.ago, primary_organisation_id: nil }

    before do
      create :metric, edition: edition1, upviews: 20, date: 15.days.ago
      create :metric, edition: edition2, upviews: 10, date: 15.days.ago
      recalculate_aggregations!
    end

    it "returns content from all organisations" do
      response = described_class.call(filter: filter.merge(organisation_id: "all"))
      expect(response[:results]).to contain_exactly(
        hash_including(base_path: edition1.base_path),
        hash_including(base_path: edition2.base_path),
      )
    end
  end

  describe "Filter by no organisations" do
    let(:edition1) { create :edition, date: 15.days.ago, primary_organisation_id: nil }

    before do
      create :metric, edition: edition1, date: 15.days.ago
      edition2 = create :edition, date: 15.days.ago, primary_organisation_id: primary_org_id
      create :metric, edition: edition2, date: 15.days.ago
      recalculate_aggregations!
    end

    it "returns content from editions which have no organisation" do
      response = described_class.call(filter: filter.merge(organisation_id: "none"))
      expect(response[:results]).to contain_exactly(
        hash_including(base_path: edition1.base_path),
      )
    end
  end

  describe "Filter by null organisations" do
    let(:edition1) { create :edition, date: 15.days.ago, primary_organisation_id: nil }
    let(:edition2) { create :edition, date: 15.days.ago, primary_organisation_id: primary_org_id }

    before do
      create :metric, edition: edition1, date: 15.days.ago
      create :metric, edition: edition2, date: 15.days.ago
      recalculate_aggregations!
    end

    it "returns content from editions which have no organisation" do
      response = described_class.call(filter: filter.merge(organisation_id: nil))
      expect(response[:results]).to contain_exactly(
        hash_including(base_path: edition1.base_path),
        hash_including(base_path: edition2.base_path),
      )
    end
  end

  describe "Filter by organisation" do
    let(:primary_org_id) { nil }
    let(:org_ids) { [] }

    before do
      @edition = create(
        :edition,
        date: 15.days.ago,
        primary_organisation_id: primary_org_id,
        organisation_ids: org_ids,
      )
      create :metric, edition: @edition, date: 15.days.ago
      recalculate_aggregations!
    end

    context "when edition has matching primary org" do
      let(:primary_org_id) { SecureRandom.uuid }
      it "returns the edition" do
        response = described_class.call(filter: filter.merge(organisation_id: primary_org_id))
        expect(response[:results]).to contain_exactly(
          hash_including(base_path: @edition.base_path),
        )
      end
    end

    context "when edition has a matching associated org" do
      let(:org_ids) { [SecureRandom.uuid] }
      it "returns the edition" do
        response = described_class.call(filter: filter.merge(organisation_id: org_ids[0]))
        expect(response[:results]).to contain_exactly(
          hash_including(base_path: @edition.base_path),
        )
      end
    end

    context "when edition has neither matching primary nor associated orgs" do
      it "returns no editions" do
        response = described_class.call(filter: filter.merge(organisation_id: SecureRandom.uuid))
        expect(response[:results]).to eq([])
      end
    end
  end

  describe "Pagination" do
    before do
      4.times do |n|
        edition = create :edition,
                         base_path: "/path/#{n}",
                         primary_organisation_id: primary_org_id,
                         warehouse_item_id: "item-#{n}"
        create :metric, edition: edition, date: 15.days.ago, upviews: (100 - n)
      end

      # not live edition - should not affect total results
      old_edition = create :edition,
                           base_path: "/path/0",
                           primary_organisation_id: primary_org_id,
                           live: false,
                           warehouse_item_id: "item-0"
      create :metric, edition: old_edition, date: 15.days.ago

      recalculate_aggregations!
    end

    it "returns the first page of data with pagination info" do
      response = described_class.call(filter: filter.merge(page: 1, page_size: 2))
      expect(response[:results]).to contain_exactly(
        hash_including(base_path: "/path/0"),
        hash_including(base_path: "/path/1"),
      )
      expect(response).to include(
        page: 1,
        total_pages: 2,
        total_results: 4,
      )
    end

    it "returns the second page of data" do
      response = described_class.call(filter: filter.merge(page: 2, page_size: 2))
      expect(response[:results]).to contain_exactly(
        hash_including(base_path: "/path/2"),
        hash_including(base_path: "/path/3"),
      )
      expect(response).to include(
        page: 2,
        total_pages: 2,
        total_results: 4,
      )
    end
  end

  describe "Order" do
    context "when there are NULLS" do
      before do
        edition1 = create :edition, title: "first", primary_organisation_id: primary_org_id
        edition2 = create :edition, title: "second", primary_organisation_id: primary_org_id
        edition3 = create :edition, title: "null", primary_organisation_id: primary_org_id

        create :metric, edition: edition1, date: 15.days.ago, useful_yes: 1, useful_no: 0 # satisfaction = 1.0
        create :metric, edition: edition2, date: 15.days.ago, useful_yes: 0, useful_no: 1 # satisfaction = 0.0
        create :metric, edition: edition3, date: 15.days.ago, useful_yes: 0, useful_no: 0 # satisfaction = NULL
        recalculate_aggregations!
      end

      it "orders NULL last when in ascending direction" do
        response = described_class.call(filter: filter.merge(sort_attribute: "satisfaction", sort_direction: "asc"))

        titles = response.fetch(:results).map { |result| result.fetch(:title) }
        expect(titles).to eq(%w[second first null])
      end

      it "orders NULL last when in descending direction" do
        response = described_class.call(filter: filter.merge(sort_attribute: "satisfaction", sort_direction: "desc"))

        titles = response.fetch(:results).map { |result| result.fetch(:title) }
        expect(titles).to eq(%w[first second null])
      end
    end

    context "when values do not repeat" do
      before do
        edition1 = create :edition, title: "last", primary_organisation_id: primary_org_id
        edition2 = create :edition, title: "middle", primary_organisation_id: primary_org_id
        edition3 = create :edition, title: "first", primary_organisation_id: primary_org_id

        create :metric, edition: edition1, date: 15.days.ago, upviews: 1, feedex: 3
        create :metric, edition: edition2, date: 15.days.ago, upviews: 2, feedex: 2
        create :metric, edition: edition3, date: 15.days.ago, upviews: 3, feedex: 1
        recalculate_aggregations!
      end

      it "defaults order by descending unique pageviews" do
        response = described_class.call(filter: filter)

        titles = response.fetch(:results).map { |result| result.fetch(:title) }
        expect(titles).to eq(%w[first middle last])
      end

      it "order by other attribute" do
        response = described_class.call(filter: filter.merge(sort_attribute: "feedex"))

        titles = response.fetch(:results).map { |result| result.fetch(:title) }
        expect(titles).to eq(%w[last middle first])
      end

      it "order in ascending" do
        response = described_class.call(filter: filter.merge(sort_direction: "asc"))

        titles = response.fetch(:results).map { |result| result.fetch(:title) }
        expect(titles).to eq(%w[last middle first])
      end
    end

    context "when values repeat" do
      before do
        edition1 = create :edition, title: "first", warehouse_item_id: "w1", primary_organisation_id: primary_org_id
        edition2 = create :edition, title: "second", warehouse_item_id: "w2", primary_organisation_id: primary_org_id

        create :metric, edition: edition1, date: 15.days.ago, upviews: 1
        create :metric, edition: edition2, date: 15.days.ago, upviews: 1
        recalculate_aggregations!
      end

      it "use column `warehouse_item_id` to ensure unique order" do
        response = described_class.call(filter: filter.merge(sort_attribute: "upviews"))

        titles = response.fetch(:results).map { |result| result.fetch(:title) }
        expect(titles).to eq(%w[second first])
      end

      it "respects the sort direction when sorting by `warehouse_item_id`" do
        response = described_class.call(filter: filter.merge(sort_attribute: "upviews", sort_direction: "asc"))

        titles = response.fetch(:results).map { |result| result.fetch(:title) }
        expect(titles).to eq(%w[first second])
      end
    end
  end

  describe "when no useful_yes/no.. responses" do
    before do
      edition = create :edition, primary_organisation_id: primary_org_id
      create :metric, edition: edition, date: 15.days.ago, useful_yes: 0, useful_no: 0

      recalculate_aggregations!
    end

    it "returns the nil for the satisfaction" do
      results = described_class.call(filter: filter)
      expect(results[:results].first).to include(
        satisfaction: nil,
      )
    end
  end

  describe "when no metrics in the date range" do
    before do
      create :edition, date: "2018-02-01"

      recalculate_aggregations!
    end

    it "returns a empty array" do
      results = described_class.call(filter: filter)
      expect(results[:results]).to be_empty
    end
  end

  describe "when invalid filter" do
    it "raises an error if no `organisation_id` attribute" do
      filter.delete :organisation_id

      expect(-> { described_class.call(filter: filter) }).to raise_error(ArgumentError)
    end

    it "raises an error if no `date_range` attribute" do
      filter.delete :date_range

      expect(-> { described_class.call(filter: filter) }).to raise_error(ArgumentError)
    end
  end

  describe "Filter by title / url" do
    it "returns the editions matching a title" do
      edition1 = create :edition, title: "this is a big title", date: 2.months.ago, primary_organisation_id: primary_org_id
      edition2 = create :edition, title: "this is a small title", date: 2.months.ago, primary_organisation_id: primary_org_id

      create :metric, edition: edition1, date: 15.days.ago
      create :metric, edition: edition2, date: 14.days.ago
      recalculate_aggregations!

      result = described_class.call(filter: filter.merge(search_term: "big title"))
      expect(result[:results]).to contain_exactly(
        hash_including(title: "this is a big title"),
      )
    end

    it "returns the editions matching a base_path" do
      edition1 = create :edition, base_path: "/this/is/a/big/base-path", date: 2.months.ago, primary_organisation_id: primary_org_id
      edition2 = create :edition, base_path: "/this/is/a/small/base-path", date: 2.months.ago, primary_organisation_id: primary_org_id

      create :metric, edition: edition1, date: 15.days.ago
      create :metric, edition: edition2, date: 14.days.ago
      recalculate_aggregations!

      result = described_class.call(filter: filter.merge(search_term: "big base-path"))
      expect(result[:results]).to contain_exactly(
        hash_including(base_path: "/this/is/a/big/base-path"),
      )
    end

    describe "search by base_path with full URLs" do
      before do
        edition1 = create :edition, base_path: "/base-path", date: 2.months.ago, primary_organisation_id: primary_org_id

        create :metric, edition: edition1, date: 15.days.ago
        recalculate_aggregations!
      end

      subject { described_class.call(filter: filter.merge(search_term: search_term))[:results] }

      context "when search terms include the protocol (http)" do
        let(:search_term) { "http://base-path" }

        it "return editions matching the base_path" do
          expect(subject).to contain_exactly(
            hash_including(base_path: "/base-path"),
          )
        end
      end

      context "when search terms include the protocol (https)" do
        let(:search_term) { "https://base-path" }

        it "return editions matching the base_path" do
          expect(subject).to contain_exactly(
            hash_including(base_path: "/base-path"),
          )
        end
      end

      context "when search terms include domain gov.uk" do
        let(:search_term) { "gov.uk/base-path" }

        it "return editions matching the base_path" do
          expect(subject).to contain_exactly(
            hash_including(base_path: "/base-path"),
          )
        end
      end

      context "when search terms include domain www.gov.uk" do
        let(:search_term) { "www.gov.uk/base-path" }

        it "return editions matching the base_path" do
          expect(subject).to contain_exactly(
            hash_including(base_path: "/base-path"),
          )
        end
      end
    end
  end
end
