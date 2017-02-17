require 'rails_helper'

RSpec.describe Importers::AllContentItems do
  describe '#run' do
    it 'imports content items for all organisations' do
      create(:organisation, slug: 'organisation-one')
      create(:organisation, slug: 'organisation-two')
      expect_any_instance_of(Importers::ContentItemsByOrganisation).to receive(:run).exactly(2).times

      subject.run
    end

    it 'does not import content items if there are no organisations' do
      expect_any_instance_of(Importers::ContentItemsByOrganisation).not_to receive(:run)

      subject.run
    end
  end
end
