module Clients
  class SearchAPI
    def find_each(query_params, fields)
      start = 0

      loop do
        response = HTTParty.get(search_api_end_point(query_params, fields, start))
        results = JSON.parse(response.body).fetch('results')

        results.each { |result| yield result }

        break if last_page?(results)

        start += batch_size
      end
    end

    def batch_size
      1000
    end

  private

    def last_page?(results)
      results.length < batch_size
    end

    def search_api_end_point(query, fields, start)
      query.merge!(
        fields: fields.join(','),
        count: batch_size,
        start: start,
      )
      params = Rack::Utils.build_query(query)

      "https://www.gov.uk/api/search.json?#{params}"
    end
  end
end
