RSpec.describe InventoryRule do
  subject { FactoryGirl.build(:inventory_rule) }

  describe "validations" do
    it "has a valid factory" do
      expect(subject).to be_valid
    end

    it "requires a subtheme" do
      subject.subtheme = nil
      expect(subject).to be_invalid
    end

    it "requires a link_type" do
      subject.link_type = ""
      expect(subject).to be_invalid
    end

    it "requires a target_content_id" do
      subject.target_content_id = ""
      expect(subject).to be_invalid
    end
  end
end
