require 'rails_helper'

RSpec.describe OrganisationsHelper, type: :helper do
  describe '#stringify_organisations', :stringify_organisations do
    let(:organisations) { build_list(:organisation, 2) }
    before do
      assign(:organisations, organisations)
      organisations[0].title = 'An Organisation'
      organisations[1].title = 'Another Organisation'
    end

    subject { helper.stringify_organisations(organisations) }

    it 'has a comma between names' do
      expect(subject).to have_text('An Organisation, Another Organisation')
    end
  end
end
