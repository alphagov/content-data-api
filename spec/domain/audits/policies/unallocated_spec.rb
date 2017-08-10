module Audits
  RSpec.describe Policies::Unallocated do
    subject { described_class }

    let(:user) { create :user }
    let(:unallocated) { create(:content_item) }

    it "returns unallocated content" do
      create :allocation, user: user, content_item: create(:content_item)

      scope = ContentItem.all
      expect(subject.call(scope)).to match_array(unallocated)
    end
  end
end
