class TaxonomiesService
  attr_accessor :publishing_api

  def initialize
    @publishing_api = Clients::PublishingAPI.new
  end

  def find_each
    publishing_api.find_each(attribute_names) do |taxonomy|
      yield taxonomy
    end
  end

private

  def attribute_names
    @names ||= %i(content_id title)
  end
end
