require "rails_helper"

RSpec.describe ContentItemDecorator, type: :decorator do
  describe '#organisation_links' do
    let(:organisations) do
      [
        build(:organisation, slug: 'slug-1', title: 'title-1'),
        build(:organisation, slug: 'slug-2', title: 'title-2')
      ]
    end

    let(:content_item) { build(:content_item, organisations: organisations).decorate }

    it 'has a comma between names' do
      organisation_links = content_item.organisation_links

      expect(organisation_links).to include(%{<a href=\"/content_items?organisation_slug=slug-1\">title-1</a>})
      expect(organisation_links).to include(%{<a href=\"/content_items?organisation_slug=slug-2\">title-2</a>})
    end
  end
end
