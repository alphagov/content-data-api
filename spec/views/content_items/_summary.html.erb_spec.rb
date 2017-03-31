require 'rails_helper'

RSpec.describe 'content_items/_summary.html.erb', type: :view do
  let(:metrics) {
    {
      total_pages: { value: 0 },
      zero_page_views: { value: 0 }
    }
  }

  it "renders the total pages metric" do
    metrics[:total_pages][:value] = 123
    assign(:metrics, metrics)

    render

    expect(rendered).to have_selector(".summary-item-label", text: "Live pages")
    expect(rendered).to have_selector(".summary-item-value", text: "123")
  end

  it "renders the zero page views metric" do
    metrics[:zero_page_views][:value] = 123
    assign(:metrics, metrics)

    render

    expect(rendered).to have_selector(".summary-item-label", text: "Pages with zero views")
    expect(rendered).to have_selector(".summary-item-value", text: "123")
  end
end
