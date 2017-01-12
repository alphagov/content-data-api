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

      content_item.update!(attributes)
    end
  end
end
