module Audits
  RSpec.describe Policies::Allocated do
    subject { described_class }

    let(:user) { create :user }
    let(:unallocated) { create(:content_item) }

    it "returns content allocated to a user" do
      allocated = create(:content_item)
      create :allocation, user: user, content_item: allocated

      scope = ContentItem.all
      expect(subject.call(scope, allocated_to: user.id)).to match_array(allocated)
      expect(subject.call(scope, allocated_to: create(:user).id)).to be_empty
    end
  end
end
