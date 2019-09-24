RSpec.describe Streams::ParentChild::LinksProcessor do
  let!(:parent) { create :edition, child_sort_order: ["child-1:en", "child-2:en"], warehouse_item_id: "parent:en" }
  let!(:child_2) { create :edition, warehouse_item_id: "child-2:en" }
  let!(:child_1) { create :edition, warehouse_item_id: "child-1:en" }

  subject { described_class }

  context "when the edition has children" do
    it "looks up the children and applies the sort order" do
      subject.update_parent_and_sort_siblings(parent, nil)

      expected = [
        ["child-1:en", 1],
        ["child-2:en", 2],
      ]
      expect(parent.children.order(:sibling_order).pluck(:warehouse_item_id, :sibling_order)).to eq(expected)
    end
  end

  context "when the edition has a parent" do
    it "looks up the parent and applies the sort order" do
      subject.update_parent_and_sort_siblings(child_1, "parent:en")

      expected = [
        ["child-1:en", 1],
        ["child-2:en", 2],
      ]
      expect(parent.children.order(:sibling_order).pluck(:warehouse_item_id, :sibling_order)).to eq(expected)
    end
  end
end
