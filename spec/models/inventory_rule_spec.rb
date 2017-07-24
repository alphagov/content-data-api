RSpec.describe InventoryRule do
  subject { build(:inventory_rule) }

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

    it "requires a unique target_content_id scoped to subtheme and link_type" do
      existing = create(:inventory_rule, target_content_id: "id123")

      subject.target_content_id = "id123"
      expect(subject).to be_valid

      subject.link_type = existing.link_type
      expect(subject).to be_valid

      subject.subtheme = existing.subtheme
      expect(subject).to be_invalid
    end

    it "has case-insensitive uniqueness" do
      existing = create(:inventory_rule, target_content_id: "id123")

      subject.subtheme = existing.subtheme
      subject.link_type = existing.link_type
      subject.target_content_id = "ID123"

      expect(subject).to be_invalid
    end
  end
end
