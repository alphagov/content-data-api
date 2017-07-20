RSpec.describe Search::Sort do
  let(:search) { Search.new }

  describe "sorting" do
    context "by page views (6 months)" do
      before do
        create(:content_item, six_months_page_views: 0)
        create(:content_item, six_months_page_views: 999)
      end

      it "sorts in ascending order" do
        search.sort = :six_months_page_views_desc
        search.execute
        expect(results.pluck(:six_months_page_views)).to eq [999, 0]
      end

      it "sorts in descending order" do
        search.sort = :six_months_page_views_asc
        search.execute
        expect(results.pluck(:six_months_page_views)).to eq [0, 999]
      end
    end

    context "by page views (1 month)" do
      before do
        create(:content_item, one_month_page_views: 0)
        create(:content_item, one_month_page_views: 999)
      end

      it "sorts in ascending order" do
        search.sort = :one_month_page_views_desc
        search.execute
        expect(results.pluck(:one_month_page_views)).to eq [999, 0]
      end

      it "sorts in descending order" do
        search.sort = :one_month_page_views_asc
        search.execute
        expect(results.pluck(:one_month_page_views)).to eq [0, 999]
      end
    end

    context "by page title" do
      before do
        create(:content_item, title: "AAA")
        create(:content_item, title: "BBB")
      end

      it "sorts in ascending order" do
        search.sort = :title_asc
        search.execute
        expect(results.pluck(:title)).to eq %w(AAA BBB)
      end

      it "sorts in descending order" do
        search.sort = :title_desc
        search.execute
        expect(results.pluck(:title)).to eq %w(BBB AAA)
      end
    end

    context "by document type" do
      before do
        create(:content_item, document_type: "DOC-TYPE-AAA")
        create(:content_item, document_type: "DOC-TYPE-BBB")
      end

      it "sorts in ascending order" do
        search.sort = :document_type_asc
        search.execute
        expect(results.pluck(:document_type)).to eq ["DOC-TYPE-AAA", "DOC-TYPE-BBB"]
      end

      it "sorts in descending order" do
        search.sort = :document_type_desc
        search.execute
        expect(results.pluck(:document_type)).to eq ["DOC-TYPE-BBB", "DOC-TYPE-AAA"]
      end
    end

    context "by public updated at" do
      let!(:time) { Time.parse("2017-01-10") }
      let!(:older_time) { Time.parse("2017-01-01") }

      before do
        create(:content_item, public_updated_at: time)
        create(:content_item, public_updated_at: older_time)
      end

      it "sorts in ascending order" do
        search.sort = :public_updated_at_asc

        expect(results.pluck(:public_updated_at)).to eq [older_time, time]
      end

      it "sorts in descending order" do
        search.sort = :public_updated_at_desc

        expect(results.pluck(:public_updated_at)).to eq [time, older_time]
      end
    end

    def results
      search.execute
      search.content_items
    end
  end
end
