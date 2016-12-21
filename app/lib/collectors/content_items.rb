module Collectors
  class ContentItems
    def find_each(organisation_slug)
      raise 'missing block!' unless block_given?

      query_params = { filter_organisations: organisation_slug }
      fields = %w(content_id link title organisations)

      Clients::SearchAPI.new.find_each(query_params, fields) do |attributes|
        yield attributes
      end
    end
  end
end
