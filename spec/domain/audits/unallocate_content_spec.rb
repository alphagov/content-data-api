module Audits
  RSpec.describe UnallocateContent do
    it "Unallocates content items" do
      user = create :user
      item1 = create :content_item, content_id: "content_id_1"
      item2 = create :content_item, content_id: "content_id_2"

      create(:allocation, user: user, content_item: item1)
      create(:allocation, user: user, content_item: item2)

      UnallocateContent.call(content_ids: %w(content_id_1))

      expect(Allocation.count).to eq(1)
      expect(Allocation.first.user).to eq(user)
      expect(Allocation.first.content_item).to eq(item2)
    end
  end
end
