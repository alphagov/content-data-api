RSpec.describe 'sorting' do
  let(:query) { Content::Query.new }

  describe "sorting" do
    context "by page views (6 months)" do
      before do
        create(:content_item, six_months_page_views: 0, content_id: 'b')
        create(:content_item, six_months_page_views: 0, content_id: 'a')
        create(:content_item, six_months_page_views: 0, content_id: 'c')
        create(:content_item, six_months_page_views: 999, content_id: 'z')

        query.sort(:six_months_page_views)
      end

      it "sorts in descending order" do
        query.sort_direction(:desc)
        expect(query.content_items.pluck(:six_months_page_views)).to eq [999, 0, 0, 0]
      end

      it "sorts in ascending order" do
        query.sort_direction(:asc)
        expect(query.content_items.pluck(:six_months_page_views)).to eq [0, 0, 0, 999]
      end

      it "breaks ties on ascending base path" do
        query.sort_direction(:asc)
        expect(query.content_items.pluck(:content_id)).to contain_exactly('a', 'b', 'c', 'z')
      end
    end

    context "by page views (1 month)" do
      before do
        create(:content_item, one_month_page_views: 0)
        create(:content_item, one_month_page_views: 999)
      end

      it "sorts in descending order" do
        query
          .sort(:one_month_page_views)
          .sort_direction(:desc)
        expect(query.content_items.pluck(:one_month_page_views)).to eq [999, 0]
      end

      it "sorts in ascending order" do
        query
          .sort(:one_month_page_views)
          .sort_direction(:asc)
        expect(query.content_items.pluck(:one_month_page_views)).to eq [0, 999]
      end
    end

    context "by page title" do
      before do
        create(:content_item, title: "AAA")
        create(:content_item, title: "BBB")
      end

      it "sorts in ascending order" do
        query
          .sort(:title)
          .sort_direction(:asc)
        expect(query.content_items.pluck(:title)).to eq %w(AAA BBB)
      end

      it "sorts in descending order" do
        query
          .sort(:title)
          .sort_direction(:desc)
        expect(query.content_items.pluck(:title)).to eq %w(BBB AAA)
      end
    end

    context "by document type" do
      before do
        create(:content_item, document_type: "DOC-TYPE-AAA")
        create(:content_item, document_type: "DOC-TYPE-BBB")
      end

      it "sorts in ascending order" do
        query
          .sort(:document_type)
          .sort_direction(:asc)
        expect(query.content_items.pluck(:document_type)).to eq ["DOC-TYPE-AAA", "DOC-TYPE-BBB"]
      end

      it "sorts in descending order" do
        query
          .sort(:document_type)
          .sort_direction(:desc)
        expect(query.content_items.pluck(:document_type)).to eq ["DOC-TYPE-BBB", "DOC-TYPE-AAA"]
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
        query
          .sort(:public_updated_at)
          .sort_direction(:asc)
        expect(query.content_items.pluck(:public_updated_at)).to eq [older_time, time]
      end

      it "sorts in descending order" do
        query
          .sort(:public_updated_at)
          .sort_direction(:desc)
        expect(query.content_items.pluck(:public_updated_at)).to eq [time, older_time]
      end
    end
  end
end
