class Importers::Organisation

  attr_reader :slug, :batch, :start

  def initialize(slug, batch: 10, start: 0)
    @slug = slug
    @batch = batch
    @start = start
  end

  def run
    organisation = ::Organisation.create!(slug: slug)
    loop do
      response = HTTParty.get "https://www.gov.uk/api/search.json?filter_organisations=#{slug}&count=#{batch}&fields=content_id&start=#{start}"
      results = JSON.parse(response.body).fetch('results')

      raise "No result for slug" if results.empty? && organisation.content_items.empty?

      results.each do |result|
        attributes = result.slice('content_id')
        organisation.content_items << ContentItem.new(attributes)
      end

      break if results.length < batch
      start += batch
    end
  end
end

