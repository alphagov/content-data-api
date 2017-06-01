RSpec.describe Search::Sort do
  describe ".find_by" do
    it "raises for an unrecognised sort" do
      expect { described_class.find_by(:unknown_sort_value) }
        .to raise_error(::SortError, /unrecognised/)
    end

    it "returns the Sort object for an identifier" do
      sort = described_class.find_by(:page_views_desc)

      expect(sort).to be_an_instance_of(Search::Sort)
      expect(sort.identifier).to eq(:page_views_desc)
    end
  end

  describe "apply" do
    it "sorts a scope based on the sort query" do
      scope = double
      sort = Search::Sort.new(:identifier, :sort_query)

      expect(scope).to receive(:order).with(:sort_query)
      sort.apply(scope)
    end
  end
end
