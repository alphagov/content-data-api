class ContentItemsService
  attr_accessor :publishing_api

  def initialize
    @publishing_api = Clients::PublishingAPI.new
  end

  def find_each(document_type)
    raise 'missing block!' unless block_given?

    publishing_api.find_each(query_fields, build_query_options(document_type)) do |content_item|
      content_item[:taxons] = content_item[:links][:taxons] || []
      content_item[:organisations] = content_item[:links][:organisations] || []
      yield content_item
    end
  end

private

  def build_query_options(document_type)
    { document_type: document_type, links: true }
  end

  def query_fields
    @fields ||= %i(content_id description title public_updated_at document_type base_path details)
  end
end
