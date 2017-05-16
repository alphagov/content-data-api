require 'rails_helper'

RSpec.describe Metrics::PagesWithPdfs do
  subject { Metrics::PagesWithPdfs }

  let!(:content_items) {
    [
      create(:content_item, number_of_pdfs: 1),
      create(:content_item, number_of_pdfs: 0)
    ]
  }

  it "returns the number of items with pdfs in the collection" do
    result = subject.new(ContentItem.all).run

    expect(result[:pages_with_pdfs][:value]).to eq(1)
  end

  it "returns the number of items with pdfs as a percentage of the collection" do
    result = subject.new(ContentItem.all).run

    expect(result[:pages_with_pdfs][:percentage]).to eq(50)
  end
end
