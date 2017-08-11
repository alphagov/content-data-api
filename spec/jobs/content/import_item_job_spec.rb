module Content
  RSpec.describe ImportItemJob, type: :job do
    it "calls the single content item importer" do
      expect(Importers::SingleContentItem).to receive(:run).with(content_id: "id-123", locale: "en")
      subject.perform(content_id: "id-123", locale: "en")
    end
  end
end
