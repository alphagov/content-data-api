module Collectors
  class ContentItems
    def find_each(organisation_slug)
      raise 'missing block!' unless block_given?

      query_params = { filter_organisations: organisation_slug }
      fields = %w(link)

      Clients::SearchAPI.new.find_each(query_params, fields) do |attributes|
        link = attributes.fetch(:link)
        content_item_attributes = %i(content_id description title public_updated_at document_type link)

        yield Clients::ContentStore.new.fetch(link, content_item_attributes)
      end
    end
  end
end
