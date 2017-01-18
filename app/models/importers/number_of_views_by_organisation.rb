module Importers
  class NumberOfViewsByOrganisation
    def run(slug)
      organisation = ::Organisation.find_by(slug: slug)

      content_items = ::ContentItem.where(organisation_id: organisation.id)
      base_paths = content_items.pluck(:base_path)

      results = GoogleAnalyticsService.new.page_views(base_paths)
      results.each do |result|
        content_item = ::ContentItem.find_by(base_path: result[:base_path])
        content_item.update!(unique_page_views: result[:page_views])
      end
    end
  end
end
