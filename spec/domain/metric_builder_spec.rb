module Performance
  RSpec.describe MetricBuilder do
    describe "#run_all" do
      let(:content_item) { create :content_item, number_of_pdfs: 1, number_of_word_files: 2 }
      it "calls each metric class once" do
        result = subject.run_all(content_item)
        expect(result).to eq(number_of_pdfs: 0, number_of_word_files: 0)
      end
    end

    describe "#run_collection" do
      it "return collection metrics" do
        create :content_item, number_of_pdfs: 1, number_of_word_files: 1
        create :content_item, number_of_pdfs: 0, number_of_word_files: 2
        create :content_item, number_of_pdfs: 1, number_of_word_files: 1
        create :content_item, one_month_page_views: 2

        result = subject.run_collection(Item.all)
        expected_result = {
          total_pages: { value: 4 },
          zero_page_views: { value: 3 },
          pages_not_updated: { value: 0 },
          pages_with_pdfs: { value: 2, percentage: 50.0 },
          pages_with_word_files: { value: 3, percentage: 75.0 }
        }

        expect(result).to eq(expected_result)
      end
    end
  end
end
