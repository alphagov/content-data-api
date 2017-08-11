module Content
  RSpec.describe Importers::AllContentItems do
    before do
      allow(subject.content_items_service)
        .to receive(:fetch_all_with_default_locale_only)
          .and_return([
            { content_id: "id-123", locale: "en" },
            { content_id: "id-456", locale: "cy" },
          ])
    end

    describe '#run' do
      it 'creates a job for each content item to import' do
        expect(ImportItemJob).to receive(:perform_later).with("id-123", "en")
        expect(ImportItemJob).to receive(:perform_later).with("id-456", "cy")

        subject.run
      end
    end
  end
end
