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

      base_path = attributes.fetch(:base_path)
      attributes = attributes.merge(number_of_views: number_of_views(base_path))

      content_item.update!(attributes)
    end

    def number_of_views(base_path)
      responses = GoogleAnalyticsService.new.page_views([base_path])
      responses.each do |response|
        return response[:page_views] if response[:base_path] == base_path
      end
    end
  end
end
