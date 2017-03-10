require "rails_helper"

RSpec.describe ContentItemsDecorator, type: :decorator do
  include Draper::ViewHelpers

  context 'without organisation' do
    it 'renders the default page title' do
      helpers.stub(params: {})
      content_items = [build(:content_item)]
      subject = ContentItemsDecorator.new(content_items)

      expect(subject.header).to eq('GOV.UK')
    end
  end

  context 'with organisation filter' do
    let(:organisation) { create(:organisation, title: 'Organisation title', slug: 'the-slug') }

    it 'renders the organisation title as page title' do
      helpers.stub(params: { organisation_slug: 'the-slug' })
      content_items = [build(:content_item, organisations: [organisation])]
      subject = ContentItemsDecorator.new(content_items)

      expect(subject.header).to eq('Organisation title')
    end
  end
end
