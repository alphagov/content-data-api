require 'rails_helper'

RSpec.describe Importers::AllContentItems do
  before do
    allow(subject.content_items_service)
      .to receive(:content_ids)
      .and_return(%w(id-123 id-456))
  end

  describe '#run' do
    it 'creates a job for each content item to import' do
      expect(ImportContentItemJob).to receive(:perform_later).with("id-123")
      expect(ImportContentItemJob).to receive(:perform_later).with("id-456")

      subject.run
    end
  end
end
