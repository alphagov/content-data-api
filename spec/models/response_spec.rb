RSpec.describe Response do
  describe "validations" do
    subject { FactoryGirl.build(:response) }

    it "has a valid factory" do
      expect(subject).to be_valid
    end

    it "requires an audit" do
      subject.audit = nil
      expect(subject).to be_invalid
    end

    it "requires a question" do
      subject.question = nil
      expect(subject).to be_invalid
    end
  end
end
