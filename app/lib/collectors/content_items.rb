module Collectors
  class ContentItems
    def find_each(organisation_slug)
      raise 'missing block!' unless block_given?

      query_params = { filter_organisations: organisation_slug }
      fields = %w(link)

      Clients::SearchAPI.find_each(query_params, fields) do |attributes|
        base_path = attributes.fetch(:link)
        content_item_attributes = %i(content_id description title public_updated_at document_type base_path)

        yield Clients::ContentStore.find(base_path, content_item_attributes)
      end
    end
  end
end
