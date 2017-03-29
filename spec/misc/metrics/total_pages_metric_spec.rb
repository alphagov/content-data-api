require 'rails_helper'

RSpec.describe Metrics::TotalPagesMetric do
  subject { Metrics::TotalPagesMetric }

  let(:content_items) { build_list(:content_item, 5) }

  it "returns the number of items in the collection" do
    expect(subject.new(content_items).build[:total_pages]).to eq(value: 5)
  end
end
