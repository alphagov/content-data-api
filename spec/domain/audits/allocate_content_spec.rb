module Audits
  RSpec.describe AllocateContent do
    let!(:user) { create :user }
    let!(:content_item) { create :content_item, content_id: "content_id_1" }

    it "creates a new allocation if content is not allocated" do
      AllocateContent.call(
        user_uid: user.uid,
        content_ids: %w(content_id_1)
      )

      allocation = Allocation.first
      expect(allocation.content_item).to eq(content_item)
      expect(allocation.user).to eq(user)
    end

    it "updates the user if allocation is allocated to another user" do
      another_user = create :user
      create(:allocation, user: another_user, content_item: content_item)

      AllocateContent.call(
        user_uid: user.uid,
        content_ids: %w(content_id_1)
      )

      expect(Allocation.count).to eq(1)
      expect(Allocation.first.user).to eq(user)
    end
  end
end
