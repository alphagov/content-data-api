class TaxonomiesService
  attr_accessor :publishing_api

  def initialize
    @publishing_api = Clients::PublishingAPI.new
  end

  def find_each
    publishing_api.find_each(query_fields, query_options) do |taxonomy|
      yield taxonomy
    end
  end

private

  def query_options
    @options ||= { document_type: "taxon" }
  end

  def query_fields
    @fields ||= %i(content_id title)
  end
end
