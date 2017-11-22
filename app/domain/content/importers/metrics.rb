module Content
  module Importers
    class Metrics
      def initialize(content_ids)
        @content_ids = content_ids
        @start_date = 3.months.ago.to_date
      end

      def import
        start_time = Time.now

        metrics = @content_ids
          .map { |content_id| fetch_metrics(content_id) }
          .flatten

        fetched_metrics_end = Time.now
        puts "Fetched all in #{fetched_metrics_end - start_time}s"

        puts "Writing metrics to database..."
        Content::Metric.import(metrics)
        puts "Imported all in #{Time.now - fetched_metrics_end}s"
      end

    private

      def fetch_metrics(content_id)
        puts "Fetching metrics for #{content_id} ..."
        versions = fetch_versions(content_id)

        metrics_by_version = MetricsByVersion.new

        metrics = (@start_date..Date.today).map do |date|
          version = versions.find { |v| Date.parse(v[:updated_at]) <= date }
          metrics_for_version = metrics_by_version.fetch_or_calculate(version)

          metrics_for_version && Content::Metric.new({
            content_id: version[:content_id],
            date: date,
          }.merge(metrics_for_version.to_h))
        end

        metrics.compact
      end

      def fetch_versions(content_id)
        versions = []
        preceding_version_number = nil

        loop do
          content_item = publishing_api.fetch(
            content_id,
            version: preceding_version_number,
          )

          versions << content_item

          preceding_version_number = fetch_preceding_version_number(content_item)
          updated_at_date = Date.parse(content_item[:updated_at]).to_date

          break unless preceding_version_number && updated_at_date > @start_date
        end

        versions
      end

      def publishing_api
        @publishing_api ||= Clients::PublishingAPI.new
      end

      def fetch_preceding_version_number(content_item)
        content_item[:state_history]
          .map { |version_number, _| Integer(version_number.to_s) }
          .select { |version_number| version_number < content_item[:user_facing_version] }
          .sort
          .last
      end

      def store_metric(content_item, date:, title_length:, reading_grade:)
        Content::Metric
          .create_with(
            title_length: title_length,
            reading_grade: reading_grade
          )
          .find_or_create_by(
            content_id: content_item[:content_id],
            date: date,
          )
      end

      class MetricsByVersion
        def initialize
          @metrics_by_version = {}
        end

        def fetch_or_calculate(content_item)
          return nil unless content_item

          @metrics_by_version.fetch(content_item[:user_facing_version]) do |version_number|
            @metrics_by_version.store(
              version_number,
              Content::MetricCalculator.new(content_item)
            )
          end
        end
      end
    end
  end
end
