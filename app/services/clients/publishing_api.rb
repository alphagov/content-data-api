require 'gds_api/publishing_api_v2'

module Clients
  class PublishingAPI
    attr_accessor :publishing_api, :per_page

    def initialize
      @publishing_api = GdsApi::PublishingApiV2.new(
        Plek.new.find('publishing-api'),
        disable_cache: true,
        bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
      )
      @per_page = 100
    end

    def find_each(fields)
      current_page = 1
      loop do
        response = publishing_api.get_content_items(
          document_type: 'taxon',
          order: '-public_updated_at',
          q: '',
          page: current_page,
          per_page: per_page,
          states: ['published'],
        )

        taxonomies = map_taxon_results(response['results'], fields)
        taxonomies.each { |taxon| yield taxon }
        break if last_page?(response)
        current_page = response["current_page"] + 1
      end
    end

  private

    def last_page?(response)
      response["pages"] == response["current_page"]
    end

    def map_taxon_results(taxon_results, fields)
      taxon_results.map { |taxon_hash| taxon_hash.symbolize_keys.slice(*fields) }
    end
  end
end
