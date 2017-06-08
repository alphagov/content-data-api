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

    it "requires a unique name" do
      FactoryGirl.create(:theme, name: "Environment")

      subject.name = "Environment"
      expect(subject).to be_invalid
    end

    it "has case-insensitive uniqueness" do
      FactoryGirl.create(:theme, name: "Environment")

      subject.name = "environment"
      expect(subject).to be_invalid
    end
  end
end
