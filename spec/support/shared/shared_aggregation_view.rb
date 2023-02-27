RSpec.shared_examples "calculates satisfaction" do |date|
  it "returns score with responses" do
    edition1 = create :edition, base_path: "/path1", date: 2.months.ago
    create :metric, edition: edition1, date:, useful_yes: 1, useful_no: 1

    recalculate_aggregations!

    expect(subject.first).to have_attributes(satisfaction: 0.5)
  end

  it "returns nil with no responses" do
    edition1 = create :edition, base_path: "/path1", date: 2.months.ago
    create :metric, edition: edition1, date:, useful_yes: 0, useful_no: 0

    recalculate_aggregations!

    expect(subject.first).to have_attributes(satisfaction: nil)
  end
end

RSpec.shared_examples "includes edition attributes" do |date|
  it "returns edition attributes" do
    edition1 = create(
      :edition,
      base_path: "/path1",
      title: "title",
      document_type: "guide",
      primary_organisation_id: "org_a",
      organisation_ids: %w[org_b org_c],
      date: 2.months.ago,
    )
    create :metric, edition: edition1, date:, useful_yes: 1, useful_no: 1

    recalculate_aggregations!

    expect(subject.first).to have_attributes(
      base_path: "/path1",
      title: "title",
      document_type: "guide",
      primary_organisation_id: "org_a",
      organisation_ids: %w[org_b org_c],
    )
  end
end
