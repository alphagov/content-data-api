RSpec.describe Search::Query do
  describe "per_page" do
    it "defaults to 25" do
      expect(subject.per_page).to eq(25)
    end

    it "coerces strings to integers" do
      subject.per_page = "3"
      expect(subject.per_page).to eq(3)
    end

    it "limits to 100" do
      subject.per_page = 101
      expect(subject.per_page).to eq(100)
    end
  end

  describe "page" do
    it "defaults to 1" do
      expect(subject.page).to eq(1)
    end

    it "coerces strings to integers" do
      subject.page = "3"
      expect(subject.page).to eq(3)
    end

    it "sets to 1 if <= 0" do
      subject.page = 0
      expect(subject.page).to eq(1)

      subject.page = -123
      expect(subject.page).to eq(1)
    end
  end

  describe "sort" do
    it "defaults to page_views_desc" do
      expect(subject.sort).to eq(:page_views_desc)
    end
  end

  describe "#filter_by" do
    it "raises an error if a filter already exists for a type" do
      subject.filter_by(link_type: "organisations", target_ids: "org1")

      expect { subject.filter_by(link_type: "organisations", target_ids: "org1") }
        .to raise_error(FilterError, /duplicate/)
    end

    it "raises an error if filtering by both source and target" do
      subject.filter_by(link_type: "organisations", target_ids: "org1")

      expect { subject.filter_by(link_type: "policies", source_ids: "id2") }
        .to raise_error(FilterError, /source and target/)
    end

    it "raises an error if constructing a filter with source and target" do
      expect {
        subject.filter_by(
          link_type: "organisations",
          source_ids: "id1",
          target_ids: "org1",
        )
      }.to raise_error(FilterError, /source or target/)
    end
  end
end
