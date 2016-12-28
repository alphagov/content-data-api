class ContentItemsService
  def find_each(organisation_slug)
    raise 'missing block!' unless block_given?

    query = { filter_organisations: organisation_slug }
    fields = %w(link)

    Clients::SearchAPI.find_each(query: query, fields: fields) do |response|
      link = response.fetch(:link)

      yield Clients::ContentStore.find(link, attribute_names)
    end
  end

private

  def attribute_names
    @names ||= %i(content_id title public_updated_at document_type link)
  end
end
