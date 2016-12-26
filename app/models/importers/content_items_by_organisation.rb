module Importers
  class ContentItemsByOrganisation
    def run(slug)
      organisation = ::Organisation.find_by(slug: slug)
      ContentItemsService.new.find_each(slug) do |attributes|
        content_id = attributes.fetch(:content_id)
        content_item = organisation.content_items.find_or_create_by(content_id: content_id)
        content_item.assign_attributes(attributes)
        content_item.save!
      end
    end
  end
end
