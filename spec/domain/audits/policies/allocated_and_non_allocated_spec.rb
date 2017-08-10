module Audits
  RSpec.describe Policies::AllocatedAndNonAllocated do
    subject { described_class }

    let(:user) { create :user }
    let(:unallocated) { create(:content_item) }

    it "returns non-allocated content" do
      create :allocation, user: user, content_item: create(:content_item)

      scope = ContentItem.all
      expect(subject.call(scope)).to match_array(ContentItem.all)
    end
  end
end
