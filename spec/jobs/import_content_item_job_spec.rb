RSpec.describe ImportContentItemJob, type: :job do
  it "calls the single content item importer" do
    expect(Importers::SingleContentItem).to receive(:run).with("id-123")
    subject.perform("id-123")
  end
end
