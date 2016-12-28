class OrganisationsService
  def find_each
    raise 'missing block!' unless block_given?

    query = { filter_format: 'organisation' }
    fields = %w(slug title)

    Clients::SearchAPI.find_each(query: query, fields: fields) do |attributes|
      yield attributes
    end
  end
end
