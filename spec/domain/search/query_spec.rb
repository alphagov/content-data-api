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

    it "raises for an unrecognised sort" do
      expect { subject.sort = :page_views_asc }
        .to raise_error(SortError, /unrecognised/)
    end
  end
end
