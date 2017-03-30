require 'rails_helper'

RSpec.describe 'content_items/_summary.html.erb', type: :view do
  it "renders the total pages metric" do
    metrics = { total_pages: { value: 123 } }
    assign(:metrics, metrics)

    render

    expect(rendered).to have_selector(".summary-item-label", text: "Live pages")
    expect(rendered).to have_selector(".summary-item-value", text: "123")
  end
end
