require 'rails_helper'

RSpec.describe ContentItemsHelper, type: :helper do
  describe '#content_items_header', :content_items_header do
    context 'without organisation' do
      it 'renders the default page title' do
        expect(helper.content_items_header).to eq('GOV.UK')
      end
    end

    context 'with organisation filter' do
      let(:organisation) { build(:organisation) }

      before do
        assign(:organisation, organisation)
        organisation.title = 'Organisation title'
      end

      it 'renders the organisation title as page title' do
        expect(helper.content_items_header).to eq('Organisation title')
      end
    end
  end
end
