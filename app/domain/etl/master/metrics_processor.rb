module Etl
  module Master
    class MetricsProcessor
      include Concerns::Traceable

      def self.process(*args)
        new(*args).process
      end

      def initialize(date:)
        @date = date
      end

      def process
        time(process: :metrics) do
          create_metrics
        end
      end

    private

      attr_reader :date

      def create_metrics
        dimensions_date = Dimensions::Date.for(date)
        Dimensions::Item.where(latest: true).find_in_batches(batch_size: 50000)
          .with_index do |batch, index|
          log process: :metrics, message: "processing #{batch.length} items in batch #{index}"
          values = batch.pluck(:id).map do |value|
            {
              dimensions_date_id: dimensions_date.date,
              dimensions_item_id: value,
            }
          end
          Facts::Metric.import(values, validate: false)
        end
      rescue StandardError => e
        GovukError.notify(e)
      end
    end
  end
end
