class OrganisationsService
  attr_accessor :publishing_api

  def initialize
    @publishing_api = Clients::PublishingAPI.new
  end

  def find_each
    raise 'missing block!' unless block_given?

    publishing_api.find_each(query_fields, query_options) do |organisation|
      yield build_slug(organisation)
    end
  end

private

  def query_options
    @options ||= { document_type: 'organisation' }
  end

  def query_fields
    @fields ||= %i(base_path title)
  end

  def build_slug(organisation)
    organisation.tap do |org|
      org[:slug] = org[:base_path].tap { |b| b.slice!(path_prefix) }
      org.except!(:base_path)
    end
  end

  def path_prefix
    "/government/organisations/"
  end
end
