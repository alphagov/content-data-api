require "rails_helper"

RSpec.describe ContentItemsDecorator, type: :decorator do

  context 'without organisation' do
    it 'renders the default page title' do
      content_items = [build(:content_item, organisations: [])]
      subject = ContentItemsDecorator.new(content_items)

      expect(subject.header(nil)).to eq('GOV.UK')
    end
  end

  context 'with organisation filter' do
    let(:organisation) { build(:organisation, title: 'Organisation title') }

    it 'renders the organisation title as page title' do
      content_items = [build(:content_item, organisations: [organisation])]
      subject = ContentItemsDecorator.new(content_items)

      expect(subject.header(organisation)).to eq('Organisation title')
    end
  end
end
