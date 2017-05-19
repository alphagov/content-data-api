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

  describe "default scope" do
    it "orders by id" do
      a = FactoryGirl.create(:response)
      b = FactoryGirl.create(:response)

      a.touch
      a.save!

      expect(Response.all).to eq [a, b]
    end
  end
end
