module Content
  RSpec.describe ImportPageviewsJob, type: :job do
    it "updates the content items with pageviews" do
      content_item = create(:content_item, base_path: '/the-base-path')
      allow_any_instance_of(GoogleAnalyticsService).to receive(:page_views).with(['/the-base-path']).and_return(
        [
          {
            base_path: '/the-base-path',
            one_month_page_views: 88,
            six_months_page_views: 888
          }
        ]
      )

      subject.perform(['/the-base-path'])

      content_item.reload
      expect(content_item.one_month_page_views).to eq(88)
      expect(content_item.six_months_page_views).to eq(888)
    end
  end
end
