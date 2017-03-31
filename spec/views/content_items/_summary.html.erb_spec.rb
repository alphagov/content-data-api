require 'rails_helper'

RSpec.describe 'content_items/_summary.html.erb', type: :view do
  let(:metrics) {
    {
      total_pages: { value: 0 },
      zero_page_views: { value: 0 },
      pages_not_updated: { value: 0 },
      pages_with_pdfs: { value: 0, percentage: 0 }
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

  it "renders the pages not updated metric" do
    metrics[:pages_not_updated][:value] = 123
    assign(:metrics, metrics)

    render

    expect(rendered).to have_selector(".summary-item-label", text: "Pages not updated in 6 months")
    expect(rendered).to have_selector(".summary-item-value", text: "123")
  end

  it "renders the pages with pdfs metric" do
    metrics[:pages_with_pdfs][:percentage] = 50
    assign(:metrics, metrics)

    render

    expect(rendered).to have_selector(".summary-item-label", text: "Pages that contain PDF content")
    expect(rendered).to have_selector(".summary-item-value", text: "50.0%")
  end
end
