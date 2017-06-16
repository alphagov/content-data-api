RSpec.describe Report do
  it "outputs a header row" do
    csv = described_class.generate(Audit.none)
    expect(csv).to eq("Title,Audited by\n")
  end
end
