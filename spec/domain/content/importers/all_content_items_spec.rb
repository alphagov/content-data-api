module Content
  RSpec.describe Importers::AllContentItems do
    before do
      allow(subject.content_items_service)
        .to receive(:fetch_all_with_default_locale_only)
          .and_return([
            { content_id: "id-123", locale: "en", user_facing_version: "2" },
            { content_id: "id-456", locale: "cy", user_facing_version: "3" },
          ])
    end

    describe '#run' do
      it 'creates a job for each content item to import' do
        expect(ImportItemJob).to receive(:perform_async).with("id-123", "en", "2")
        expect(ImportItemJob).to receive(:perform_async).with("id-456", "cy", "3")

        subject.run
      end
    end
  end
end
