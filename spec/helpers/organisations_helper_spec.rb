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

    context 'linkify organisations' do
      subject { helper.stringify_organisations(organisations) }

      it "turns each organisation name into a link" do
        link_href = content_items_path(organisation_slug: organisations[0].slug)

        expect(subject).to have_link(href: link_href)
      end
    end
  end
end
