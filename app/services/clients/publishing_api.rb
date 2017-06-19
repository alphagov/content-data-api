require 'gds_api/publishing_api_v2'

module Clients
  class PublishingAPI
    PER_PAGE = 700

    attr_accessor :deprecated_publishing_api, :per_page

    def initialize
      @deprecated_publishing_api = GdsApi::PublishingApiV2.new(
        Plek.new.find('publishing-api'),
        disable_cache: true,
        bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
      )
      @per_page = 700
    end

    def content_ids
      results = paginate do |p|
        publishing_api.get_content_items({
          fields: %w(content_id),
          states: %w(published),
        }.merge(p))
      end

      results.map { |r| r.fetch(:content_id) }
    end

    def fetch(content_id)
      normalise(publishing_api.get_content(content_id))
    end

    def links(content_id)
      normalise(publishing_api.get_links(content_id)).fetch(:links)
    end

    # This is deprecated. We want to remove this soon.
    def find_each(fields, options = {})
      current_page = 1
      query = build_base_query(fields, options)

      loop do
        query = build_current_page_query(query, current_page)
        response = deprecated_publishing_api.get_content_items(query)
        response["results"].each do |result|
          if options[:links]
            result[:links] = deprecated_links(result["content_id"])
          end
          yield result.deep_symbolize_keys
        end

        break if last_page?(response)
        current_page = response["current_page"] + 1
      end
    end

  private

    # deprecated
    def deprecated_links(content_id)
      response = deprecated_publishing_api.get_links(content_id)
      response["links"]
    end

    # deprecated
    def build_base_query(fields, options)
      {
        document_type: options[:document_type],
        order: options[:order] || '-public_updated_at',
        q: options[:q] || '',
        states: ['published'],
        per_page: per_page,
        fields: fields || []
      }
    end

    # deprecated
    def build_current_page_query(query, page)
      query[:page] = page
      query
    end

    def paginate
      page = 1
      results = []

      loop do
        response = yield(page: page, per_page: PER_PAGE)
        results += normalise(response).fetch(:results)
        return results if last_page?(response)
        page += 1
      end
    end

    def normalise(response)
      response.to_hash.deep_symbolize_keys
    end

    def publishing_api
      Services.publishing_api
    end

    def last_page?(response)
      response["current_page"] == response["pages"]
    end
  end
end
