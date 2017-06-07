RSpec.describe Subtheme do
  subject { FactoryGirl.build(:subtheme) }

  describe "validations" do
    it "has a valid factory" do
      expect(subject).to be_valid
    end

    it "requires a theme" do
      subject.theme = nil
      expect(subject).to be_invalid
    end

    it "requires a name" do
      subject.name = ""
      expect(subject).to be_invalid
    end
  end
end
