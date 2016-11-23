class Importers::Organisation
  def self.run(slug, options = {})
    batch = options.fetch(:batch) { 10 }
    response = HTTParty.get "https://www.gov.uk/api/search.json?filter_organisations=#{slug}&count=#{batch}&fields=content_id"
    results = JSON.parse(response.body).fetch('results')
    organisation = ::Organisation.create!(slug: slug)

    results.each do |result|
      organisation.content_items << ContentItem.new(result.slice('content_id'))
    end
  end
end
