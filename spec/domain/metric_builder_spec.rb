module Performance
  RSpec.describe MetricBuilder do
    describe "#run_all" do
      let(:content_item) { create :content_item, number_of_pdfs: 1 }
      it "calls each metric class once" do
        result = subject.run_all(content_item)
        expect(result).to eq(number_of_pdfs: 0)
      end
    end

    describe "#run_collection" do
      it "return collection metrics" do
        create :content_item, number_of_pdfs: 1
        create :content_item, one_month_page_views: 2

        result = subject.run_collection(ContentItem.all)
        expected_result = {
          total_pages: { value: 2 },
          zero_page_views: { value: 1 },
          pages_not_updated: { value: 0 },
          pages_with_pdfs: { value: 1, percentage: 50.0 }
        }

        expect(result).to eq(expected_result)
      end
    end
  end
end
