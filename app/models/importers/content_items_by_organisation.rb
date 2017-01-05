module Importers
  class ContentItemsByOrganisation
    def run(slug)
      organisation = ::Organisation.find_by(slug: slug)
      ContentItemsService.new.find_each(slug) do |attributes|
        create_or_update!(attributes, organisation)
      end
    end

  private

    def create_or_update!(attributes, organisation)
      content_id = attributes.fetch(:content_id)
      content_item = organisation.content_items.find_or_create_by(content_id: content_id)

      updated_attributes = attributes.merge(number_of_views(content_item.link))

      content_item.update!(updated_attributes)
    end

    def number_of_views(base_path)
      response = Services::GoogleAnalytics.new.page_views([base_path])
      { number_of_views: response[base_path] }
    end
  end
end
