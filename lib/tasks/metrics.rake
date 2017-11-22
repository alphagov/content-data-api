require 'gds_api/publishing_api_v2'

namespace :metrics do
  namespace :import do
    desc "Import the Content Quality metrics from the Publishing API for a single Content Item"
    task :one, [:content_id] => [:environment] do |_, args|
      Content::Importers::Metrics.new([args[:content_id]]).import
    end

    task :all, [:document_type] => [:environment] do |_, args|
      content_ids = GdsApi::PublishingApiV2
        .new(
          Plek.new.find('publishing-api'),
          disable_cache: true,
          bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
        )
        .get_content_items(
          document_type: args[:document_type],
          per_page: 10000,
          fields: [:content_id],
        )
        .to_h["results"]
        .map { |result| result["content_id"] }

      Content::Importers::Metrics.new(content_ids).import
    end
  end

  namespace :delete do
    desc "Delete all metrics"
    task all: :environment do
      count = Content::Metric.delete_all
      puts "#{count} metrics successfully deleted"
    end
  end
end
