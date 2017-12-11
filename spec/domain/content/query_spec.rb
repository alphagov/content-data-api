RSpec.describe Content::Query do
  describe "with some content tagged to organisations, policies and topics" do
    let!(:organisation_1) { create(:organisation) }
    let!(:organisation_2) { create(:organisation) }
    let!(:policy_1) { create(:policy) }
    let!(:topic_1) { create(:topic) }
    let!(:topic_2) { create(:topic) }

    let!(:content_item_1) do
      create(
        :content_item,
        organisations: organisation_1,
      )
    end

    let!(:content_item_2) do
      create(
        :content_item,
        organisations: organisation_2,
        policies: policy_1,
        topics: topic_1,
      )
    end

    let!(:content_item_3) do
      create(
        :content_item,
        organisations: organisation_1,
        policies: policy_1,
        topics: topic_2,
      )
    end

    it "can paginate" do
      subject
        .per_page(5)
        .page(2)

      expect(subject.content_items).to have_attributes(total_pages: 2, count: 3)
    end

    it "can filter by a single organisation" do
      subject.organisations(organisation_1.content_id)
      expect(subject.content_items).to contain_exactly(content_item_1, content_item_3)
    end

    it "can filter by multiple organisations" do
      subject.organisations([organisation_1, organisation_2].map(&:content_id))
      expect(subject.content_items).to contain_exactly(content_item_1, content_item_2, content_item_3)
    end

    it "can filter by both organisation and policy" do
      subject
        .organisations(organisation_1.content_id)
        .policies(policy_1.content_id)

      expect(subject.content_items).to contain_exactly(content_item_3)
    end

    it "can filter by multiple organisations, a topic and a policy" do
      subject
        .organisations([organisation_1, organisation_2].map(&:content_id))
        .policies(policy_1.content_id)
        .topics(topic_2.content_id)

      expect(subject.content_items).to contain_exactly(content_item_3)
    end

    it "can filter by a single topic" do
      subject.topics(topic_1.content_id)

      expect(subject.content_items).to contain_exactly(content_item_2)
    end

    it "can filter by multiple topics" do
      subject.topics([topic_1, topic_2].map(&:content_id))

      expect(subject.content_items).to contain_exactly(content_item_2, content_item_3)
    end

    it "returns no results if there is no target for the type" do
      subject.organisations(policy_1.content_id)
      expect(subject.content_items).to be_empty
    end

    it "can filter by document type" do
      travel_advice = create(:content_item, document_type: "travel_advice")
      subject.document_types("travel_advice")
      expect(subject.content_items).to contain_exactly(travel_advice)
    end

    it "can return an unpaginated scope of content items" do
      subject.per_page(2)

      expect(subject.content_items.size).to eq(2)
      expect(subject.all_content_items.size).to eq(8)
    end

    it "can filter by title" do
      foo = create(:content_item, title: "barfoobaz")
      subject.title("foo")
      expect(subject.content_items).to contain_exactly(foo)
    end

    it "is not case sensitive" do
      foo = create(:content_item, title: "barfoobaz")
      subject.title("Foo")
      expect(subject.content_items).to contain_exactly(foo)
    end
  end

  describe "with 101 content items" do
    let!(:content_items) { create_list(:content_item, 101) }

    it "defaults to the page 1 with 100 per page" do
      subject.sort_direction(:asc)
      expect(subject.content_items.count).to eq 100
      expect(subject.content_items).to match_array(content_items[0..99])
    end
  end

  describe "with content items with page views" do
    let!(:content_item_1) { create(:content_item, six_months_page_views: 3) }
    let!(:content_item_2) { create(:content_item, six_months_page_views: 3) }
    let!(:content_item_3) { create(:content_item, six_months_page_views: 1) }
    let!(:content_item_4) { create(:content_item, six_months_page_views: 9) }

    describe "with default sort" do
      it "sorts by six month page views descending" do
        expect(subject.content_items).to contain_exactly(
          content_item_4,
          content_item_2,
          content_item_1,
          content_item_3,
        )
      end
    end

    describe "picking content items after another item" do
      describe "sorting by six month page views" do
        before do
          subject.sort(:six_months_page_views)
        end

        it "returns the correct results when sorted in descending order" do
          subject
            .sort_direction(:desc)
            .after(content_item_1)
          expect(subject.content_items).to contain_exactly(content_item_3)
        end

        it "returns the correct results when sorted in ascending order" do
          subject
            .sort_direction(:asc)
            .after(content_item_1)
          expect(subject.content_items).to contain_exactly(content_item_2, content_item_4)
        end

        it "returns nothing after the last result" do
          subject
            .sort_direction(:desc)
            .after(content_item_3)
          expect(subject.content_items).to be_empty
        end

        it "returns everything after the first result" do
          subject
            .sort_direction(:desc)
            .after(content_item_4)
          expect(subject.content_items).to contain_exactly(content_item_2, content_item_1, content_item_3)
        end
      end
    end
  end
end
