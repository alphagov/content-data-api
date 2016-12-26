module Collectors
  class Organisations
    def find_each
      raise 'missing block!' unless block_given?

      query_params = { filter_format: 'organisation' }
      fields = %w(slug title)

      Clients::SearchAPI.find_each(query_params, fields) do |attributes|
        yield attributes
      end
    end
  end
end
