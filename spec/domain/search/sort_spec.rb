RSpec.describe Search::Sort do
  describe "apply" do
    it "sorts a scope based on the sort query" do
      scope = double
      sort = Search::Sort.new(:identifier, :sort_query)

      expect(scope).to receive(:order).with("sort_query, content_items.id")
      sort.apply(scope)
    end
  end
end
