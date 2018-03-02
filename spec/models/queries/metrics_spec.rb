require 'rails_helper'

RSpec.describe Queries::Metrics do
  subject { described_class }

  it 'returns the metrics between two dates' do
    day0 = create(:dimensions_date, date: Date.new(2018, 1, 12))
    day1 = create(:dimensions_date, date: Date.new(2018, 1, 13))
    day2 = create(:dimensions_date, date: Date.new(2018, 1, 14))
    item1 = create(:dimensions_item, content_id: 'id1')

    create(:metric, dimensions_item: item1, dimensions_date: day0)
    metric2 = create(:metric, dimensions_item: item1, dimensions_date: day1)
    metric3 = create(:metric, dimensions_item: item1, dimensions_date: day2)

    expect(subject.run(from: day1, to: day2)).to match_array([metric2, metric3])
  end

  it 'returns the metrics between two dates filtered by path' do
    day0 = create(:dimensions_date, date: Date.new(2018, 1, 12))
    day1 = create(:dimensions_date, date: Date.new(2018, 1, 13))
    day2 = create(:dimensions_date, date: Date.new(2018, 1, 14))
    item1 = create(:dimensions_item, content_id: 'id1', base_path: '/path1')
    item2 = create(:dimensions_item, content_id: 'id2', base_path: '/path2')

    create(:metric, dimensions_item: item1, dimensions_date: day0)
    metric2 = create(:metric, dimensions_item: item1, dimensions_date: day1)
    metric3 = create(:metric, dimensions_item: item1, dimensions_date: day2)
    create(:metric, dimensions_item: item2, dimensions_date: day1)
    create(:metric, dimensions_item: item2, dimensions_date: day2)

    expect(subject.run(from: day1, to: day2, base_path: '/path1')).to match_array([metric2, metric3])
  end
end
