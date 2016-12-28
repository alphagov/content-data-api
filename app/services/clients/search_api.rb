module Clients
  class SearchAPI
    class << self
      def find_each(query, fields)
        start = 0

        loop do
          response = HTTParty.get(end_point(query, fields, start)).body
          results = JSON.parse(response).fetch('results')

          results.each { |result| yield result.slice(*fields).symbolize_keys }

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

      def end_point(query, fields, start)
        "https://www.gov.uk/api/search.json?#{query_string(fields, query, start)}"
      end

      def query_string(fields, query, start)
        query[:fields] = fields.join(',')
        query[:count] = batch_size
        query[:start] = start

        Rack::Utils.build_query(query)
      end
    end
  end
end
