RSpec.shared_examples 'calculates satisfaction' do
  it 'returns score with responses' do
    edition1 = create :edition, base_path: '/path1', date: 2.months.ago
    create :metric, edition: edition1, date: Date.yesterday, useful_yes: 1, useful_no: 1

    recalculate_aggregations!

    expect(subject.first).to have_attributes( satisfaction: 0.5)
  end

  it 'returns nil with no responses' do
    edition1 = create :edition, base_path: '/path1', date: 2.months.ago
    create :metric, edition: edition1, date: Date.yesterday, useful_yes: 0, useful_no: 0

    recalculate_aggregations!

    expect(subject.first).to have_attributes(satisfaction: nil)
  end
end
