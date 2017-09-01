RSpec.describe Audits::Plan do
  subject { described_class }

  describe "#auditors" do
    it "returns all content auditors" do
      user = create :user

      expect(subject.auditors).to match_array(user)
    end

    it "excludes auditors declared in the parameter list" do
      user1 = create :user
      user2 = create :user

      expect(subject.auditors(exclude: user1)).to match_array(user2)
    end
  end
end
