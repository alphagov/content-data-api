RSpec.describe Finders::DocumentChildren do
  include AggregationsSupport

  let(:time_period) { "past-30-days" }
  let(:sort_key) { nil }
  let(:sort_direction) { nil }
  let(:filters) do
    {
      time_period:,
      sort_key:,
      sort_direction:,
    }
  end

  subject { described_class }

  before do
    create :user
  end

  it "returns the aggregations for the past 30 days" do
    parent = create :edition, date: 2.months.ago, primary_organisation_id: "1", document_type: "manual"
    child = create(:edition, date: 2.months.ago, parent:)

    create :metric, edition: parent, date: 15.days.ago, upviews: 15, useful_yes: 1, useful_no: 1, searches: 10
    create :metric, edition: parent, date: 10.days.ago, upviews: 20, useful_yes: 24, useful_no: 74, searches: 1
    create :metric, edition: child, date: 10.days.ago, upviews: 15, useful_yes: 1, useful_no: 1, searches: 10
    create :metric, edition: child, date: 11.days.ago, upviews: 10, useful_yes: 74, useful_no: 24, searches: 11

    recalculate_aggregations!

    response = records_to_hash(subject.call(parent, filters))

    expect(response).to contain_exactly(
      hash_including(upviews: 35, searches: 11, satisfaction: 0.25),
      hash_including(upviews: 25, searches: 21, satisfaction: 0.75),
    )
  end

  it "returns the edition attributes" do
    parent = create(
      :edition,
      title: "parent",
      base_path: "/parent",
      date: 2.months.ago,
      primary_organisation_id: "1",
      document_type: "manual",
    )

    child = create(
      :edition,
      title: "child",
      base_path: "/child",
      date: 2.months.ago,
      primary_organisation_id: "2",
      document_type: "manual_section",
      sibling_order: 1,
      parent:,
    )

    create :metric, edition: parent, date: 15.days.ago
    create :metric, edition: child, date: 10.days.ago

    recalculate_aggregations!

    response = records_to_hash(subject.call(parent, filters))

    expect(response).to contain_exactly(
      hash_including(
        title: "parent",
        base_path: "/parent",
        primary_organisation_id: "1",
        document_type: "manual",
        sibling_order: nil,
      ),
      hash_including(
        title: "child",
        base_path: "/child",
        primary_organisation_id: "2",
        document_type: "manual_section",
        sibling_order: 1,
      ),
    )
  end

  context "Newly created child edition before ETL process runs" do
    it "returns edition attribute for latest editions" do
      parent = create :edition, title: "parent", date: 2.months.ago
      old_child = create(:edition, title: "old", date: 10.days.ago, parent:)

      create :metric, edition: parent, date: 15.days.ago, upviews: 1
      create :metric, edition: old_child, date: 10.days.ago, upviews: 2

      recalculate_aggregations!

      create :edition, title: "new", date: 10.days.ago, parent:, replaces: old_child

      response = records_to_hash(subject.call(parent, filters))

      expect(response).to contain_exactly(hash_including(title: "parent", upviews: 1), hash_including(title: "new", upviews: 2))
    end
  end

  context "Newly created parent edition before ETL process runs" do
    it "returns edition attribute for latest editions" do
      parent = create :edition, title: "old", date: 2.months.ago
      child = create :edition, date: 10.days.ago, parent:, title: "child"

      create :metric, edition: parent, date: 15.days.ago, upviews: 1
      create :metric, edition: child, date: 10.days.ago, upviews: 2

      recalculate_aggregations!

      new_parent = create :edition, title: "new", date: 10.days.ago, replaces: parent
      child.update!(parent: new_parent)

      response = records_to_hash(subject.call(new_parent, filters))

      expect(response).to contain_exactly(hash_including(title: "new", upviews: 1), hash_including(title: "child", upviews: 2))
    end
  end

  describe "Other date ranges" do
    let(:parent) { create :edition, date: 12.months.ago }
    subject { records_to_hash(described_class.call(parent, filters)) }

    context "when time period is last month" do
      let(:time_period) { "last-month" }
      it "returns the aggregations for last month" do
        last_month_date = (Time.zone.today - 1.month)
        child = create(:edition, date: 2.months.ago, parent:)

        create :metric, edition: parent, date: last_month_date, upviews: 1, useful_yes: 3, useful_no: 1, searches: 10
        create :metric, edition: child, date: last_month_date, upviews: 2, useful_yes: 1, useful_no: 3, searches: 20

        recalculate_aggregations!

        expect(subject).to contain_exactly(
          hash_including(upviews: 1, searches: 10, satisfaction: 0.75),
          hash_including(upviews: 2, searches: 20, satisfaction: 0.25),
        )
      end
    end

    context "when time period is past 3 months" do
      let(:time_period) { "past-3-months" }
      it "returns the aggregations for past 3 months" do
        date = (Time.zone.today - 2.months)
        child = create(:edition, date: 2.months.ago, parent:)

        create :metric, edition: parent, date:, upviews: 1, useful_yes: 3, useful_no: 1, searches: 10
        create :metric, edition: child, date:, upviews: 2, useful_yes: 1, useful_no: 3, searches: 20

        recalculate_aggregations!

        expect(subject).to contain_exactly(
          hash_including(upviews: 1, searches: 10, satisfaction: 0.75),
          hash_including(upviews: 2, searches: 20, satisfaction: 0.25),
        )
      end
    end

    context "when time period is past 6 months" do
      let(:time_period) { "past-6-months" }
      it "returns the aggregations for past 6 months" do
        date = (Time.zone.today - 5.months)
        child = create(:edition, date: 6.months.ago, parent:)

        create :metric, edition: parent, date:, upviews: 1, useful_yes: 3, useful_no: 1, searches: 10
        create :metric, edition: child, date:, upviews: 2, useful_yes: 1, useful_no: 3, searches: 20

        recalculate_aggregations!

        expect(subject).to contain_exactly(
          hash_including(upviews: 1, searches: 10, satisfaction: 0.75),
          hash_including(upviews: 2, searches: 20, satisfaction: 0.25),
        )
      end
    end

    context "when time period is past year" do
      let(:time_period) { "past-year" }
      it "returns the aggregations for past year" do
        date = (Time.zone.today - 12.months)
        child = create(:edition, date: 12.months.ago, parent:)

        create :metric, edition: parent, date:, upviews: 1, useful_yes: 3, useful_no: 1, searches: 10
        create :metric, edition: child, date:, upviews: 2, useful_yes: 1, useful_no: 3, searches: 20

        recalculate_aggregations!

        expect(subject).to contain_exactly(
          hash_including(upviews: 1, searches: 10, satisfaction: 0.75),
          hash_including(upviews: 2, searches: 20, satisfaction: 0.25),
        )
      end
    end
  end

  describe "Order" do
    let(:parent) { create :edition, title: "A" }

    before do
      edition1 = create(:edition, title: "B", sibling_order: 1, parent:)
      edition2 = create(:edition, title: "C", sibling_order: 2, parent:)

      create :metric, edition: parent, date: 15.days.ago, upviews: 1, feedex: 2, useful_yes: 1, useful_no: 0
      create :metric, edition: edition1, date: 15.days.ago, upviews: 1, feedex: 1, useful_yes: 0, useful_no: 1
      create :metric, edition: edition2, date: 15.days.ago, upviews: 1, feedex: 3, useful_yes: 0, useful_no: 0
      recalculate_aggregations!
    end

    context "when the sort key is upviews" do
      let(:sort_key) { "upviews" }

      context "and sort is ascending direction" do
        let(:sort_direction) { "asc" }

        it "secondary sorts on sibling order asc" do
          response = records_to_hash(subject.call(parent, filters))

          titles = response.map { |result| result.fetch(:title) }
          expect(titles).to eq(%w[A B C])
        end
      end

      context "and sort is desc direction" do
        let(:sort_direction) { "desc" }

        it "secondary sorts on sibling order asc" do
          response = records_to_hash(subject.call(parent, filters))

          titles = response.map { |result| result.fetch(:title) }
          expect(titles).to eq(%w[A B C])
        end
      end
    end

    context "when the sort key feedex" do
      let(:sort_key) { "feedex" }

      context "and sort is ascending direction" do
        let(:sort_direction) { "asc" }

        it "secondary sorts on feedex ascending" do
          response = records_to_hash(subject.call(parent, filters))

          titles = response.map { |result| result.fetch(:title) }
          expect(titles).to eq(%w[B A C])
        end
      end

      context "and sort is descending direction" do
        let(:sort_direction) { "desc" }

        it "secondary sorts on feedex ascending" do
          response = records_to_hash(subject.call(parent, filters))

          titles = response.map { |result| result.fetch(:title) }
          expect(titles).to eq(%w[C A B])
        end
      end
    end

    context "when the sort key satisfaction" do
      let(:sort_key) { "satisfaction" }

      context "when sort is ascending direction" do
        let(:sort_direction) { "asc" }
        it "orders NULL last when in ascending direction" do
          response = records_to_hash(subject.call(parent, filters))
          titles = response.map { |result| result.fetch(:title) }
          expect(titles).to eq(%w[B A C])
        end
      end

      context "when sort is ascending direction" do
        let(:sort_direction) { "desc" }
        it "orders NULL last when in descending direction" do
          response = records_to_hash(subject.call(parent, filters))

          titles = response.map { |result| result.fetch(:title) }
          expect(titles).to eq(%w[A B C])
        end
      end
    end
  end
end

def records_to_hash(records)
  records.to_a.map { |e| e.serializable_hash.deep_symbolize_keys }
end
