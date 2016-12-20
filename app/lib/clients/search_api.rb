module Clients
  class SearchAPI

    def find_each(slug)
      start = 0

      loop do
        response = HTTParty.get(search_api_end_point(slug, start))
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

    CONTENT_ITEM_FIELDS = %w(content_id description link title organisations).freeze
    private_constant :CONTENT_ITEM_FIELDS

    def last_page?(results)
      results.length < batch_size
    end

    def search_api_end_point(slug, start)
      "https://www.gov.uk/api/search.json?filter_organisations=#{slug}&count=#{batch_size}&fields=#{CONTENT_ITEM_FIELDS.join(',')}&start=#{start}"
    end
  end
end
