RSpec.describe Audit do
  describe "validations" do
    subject { FactoryGirl.build(:audit) }

    it "has a valid factory" do
      expect(subject).to be_valid
    end

    it "requires a content_item" do
      subject.content_item = nil
      expect(subject).to be_invalid
    end

    it "requires a user" do
      subject.user = nil
      expect(subject).to be_invalid
    end
  end
end
