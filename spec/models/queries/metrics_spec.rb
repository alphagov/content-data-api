require 'rails_helper'

RSpec.describe Queries::Metrics do
  subject { described_class }

  let(:day0) { create(:dimensions_date, date: Date.new(2018, 1, 12)) }
  let(:day1) { create(:dimensions_date, date: Date.new(2018, 1, 13)) }
  let(:day2) { create(:dimensions_date, date: Date.new(2018, 1, 14)) }

  it '.between' do
    item1 = create(:dimensions_item)

    create(:metric, dimensions_item: item1, dimensions_date: day0)
    metric2 = create(:metric, dimensions_item: item1, dimensions_date: day1)
    metric3 = create(:metric, dimensions_item: item1, dimensions_date: day2)

    expect(subject.new.between(day1, day2).relation).to match_array([metric2, metric3])
  end

  it '.by_base_path' do
    item1 = create(:dimensions_item, base_path: '/path1')
    item2 = create(:dimensions_item, base_path: '/path2')

    metric1 = create(:metric, dimensions_item: item1, dimensions_date: day0)
    metric2 = create(:metric, dimensions_item: item1, dimensions_date: day1)
    metric3 = create(:metric, dimensions_item: item1, dimensions_date: day2)
    create(:metric, dimensions_item: item2, dimensions_date: day1)
    create(:metric, dimensions_item: item2, dimensions_date: day2)

    expect(subject.new.by_base_path('/path1').relation).to match_array([metric1, metric2, metric3])
  end

  it '.by_content_id' do
    item1 = create(:dimensions_item, content_id: 'id1')
    item2 = create(:dimensions_item, content_id: 'id2')

    metric1 = create(:metric, dimensions_item: item1, dimensions_date: day0)
    metric2 = create(:metric, dimensions_item: item1, dimensions_date: day1)
    metric3 = create(:metric, dimensions_item: item1, dimensions_date: day2)
    create(:metric, dimensions_item: item2, dimensions_date: day1)
    create(:metric, dimensions_item: item2, dimensions_date: day2)

    expect(subject.new.by_content_id('id1').relation).to match_array([metric1, metric2, metric3])
  end
end
