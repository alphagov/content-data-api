RSpec.describe Theme do
  subject { FactoryGirl.build(:theme) }

  describe "validations" do
    it "has a valid factory" do
      expect(subject).to be_valid
    end

    it "requires a name" do
      subject.name = ""
      expect(subject).to be_invalid
    end
  end
end
