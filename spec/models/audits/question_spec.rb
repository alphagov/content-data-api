RSpec.describe Audits::Question do
  it "is abstract" do
    expect { Audits::Question.new }.to raise_error(/abstract class/i)
  end

  describe "validations" do
    subject { build(:boolean_question) }

    it "has a valid factory" do
      expect(subject).to be_valid
    end

    it "requires text" do
      subject.text = " "
      expect(subject).to be_invalid
    end
  end
end
