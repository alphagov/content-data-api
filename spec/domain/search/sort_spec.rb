RSpec.describe Search::Sort do
  describe "apply" do
    it "sorts a scope based on the sort query" do
      scope = double
      sort = Search::Sort.new(:identifier, :sort_field, :sort_order)

      expect(scope).to receive(:order).with("sort_field sort_order")
      sort.apply(scope)
    end
  end
end
