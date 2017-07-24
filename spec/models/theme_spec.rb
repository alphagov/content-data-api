RSpec.describe Theme do
  subject { build(:theme) }

  describe "validations" do
    it "has a valid factory" do
      expect(subject).to be_valid
    end

    it "requires a name" do
      subject.name = ""
      expect(subject).to be_invalid
    end

    it "requires a unique name" do
      create(:theme, name: "Environment")

      subject.name = "Environment"
      expect(subject).to be_invalid
    end

    it "has case-insensitive uniqueness" do
      create(:theme, name: "Environment")

      subject.name = "environment"
      expect(subject).to be_invalid
    end
  end
end
