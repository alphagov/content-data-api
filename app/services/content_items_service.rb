class ContentItemsService
  def find_each(organisation_slug)
    raise 'missing block!' unless block_given?

    query = { filter_organisations: organisation_slug }
    fields = %w(link)

    Clients::SearchAPI.find_each(query: query, fields: fields) do |response|
      base_path = response.fetch(:link)
      content_item = Clients::ContentStore.find(base_path, attribute_names)
      if content_item
        content_item[:taxons] = TaxonomyParser.parse(content_item)
        yield content_item
      end
    end
  end

private

  def attribute_names
    @names ||= %i(content_id description title public_updated_at document_type base_path details links)
  end
end
