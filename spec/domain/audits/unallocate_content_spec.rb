module Audits
  RSpec.describe UnallocateContent do
    let(:user) { create :user }

    let(:item1) { create :content_item, content_id: "content_id_1" }
    let(:item2) { create :content_item, content_id: "content_id_2" }

    before do
      create(:allocation, user: user, content_item: item1)
      create(:allocation, user: user, content_item: item2)
    end

    it "Unallocates content items" do
      UnallocateContent.call(content_ids: %w(content_id_1))

      expect(Allocation.count).to eq(1)
      expect(Allocation.first).to have_attributes(content_item: item2, user: user)
    end

    it "Returns a message with the number of unallocated items" do
      result = UnallocateContent.call(content_ids: %w(content_id_1 content_id_2))

      expect(result.message).to eq("2 items unallocated")
    end
  end
end
