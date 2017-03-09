require 'rails_helper'

RSpec.describe ImportPageviewsJob, type: :job do
  it "updates the content items with pageviews" do
    content_item = create(:content_item, base_path: '/the-base-path')
    service = double(:google_analytics_service)
    allow(service).to receive(:page_views).with(['/the-base-path']).and_return(
      [
        {
          base_path: '/the-base-path',
          one_month_page_views: 88,
          six_months_page_views: 888
        }
      ]
    )
    subject.google_analytics_service = service

    subject.perform([content_item])

    content_item.reload
    expect(content_item.one_month_page_views).to eq(88)
    expect(content_item.six_months_page_views).to eq(888)
  end
end
