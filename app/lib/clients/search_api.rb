module Clients
  class SearchAPI
    mattr_accessor :start

    def fetch(slug, batch: 10, start: 0)
      self.start = 0

      loop do
        response = HTTParty.get(search_api_end_point(slug, batch, start))
        results = JSON.parse(response.body).fetch('results')

        results.each { |result| yield result }

        break if last_page?(results, batch)

        next_page!(batch)
      end
    end

  private

    CONTENT_ITEM_FIELDS = %w(content_id link title organisations).freeze
    private_constant :CONTENT_ITEM_FIELDS

    def last_page?(results, batch)
      results.length < batch
    end

    def next_page!(batch)
      self.start = batch
    end

    def search_api_end_point(slug, batch, start)
      "https://www.gov.uk/api/search.json?filter_organisations=#{slug}&count=#{batch}&fields=#{CONTENT_ITEM_FIELDS.join(',')}&start=#{start}"
    end
  end
end
