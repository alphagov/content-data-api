require "gds_api/support_api"

class Etl::Feedex::Service
  attr_reader :date, :batch_size, :support_api

  def self.find_in_batches(*args, &block)
    new(*args).find_in_batches(&block)
  end

  def initialize(date, batch_size, support_api = nil)
    @date = date
    @batch_size = batch_size
    @support_api = support_api || support_api_with_long_timeout
  end

  def find_in_batches
    current_page = 1
    loop do
      response = support_api.feedback_by_day(date, current_page, @batch_size)
      yield convert_results(response["results"])

      break if response["pages"].zero? || response["pages"] == current_page

      current_page += 1
    end
  end

private

  def support_api_with_long_timeout
    GdsApi::SupportApi.new(
      Plek.new.find("support-api"),
      bearer_token: ENV["SUPPORT_API_BEARER_TOKEN"],
    ).tap do |client|
      client.options[:timeout] = 15
    end
  end

  def convert_results(results)
    results.map do |result|
      {
        date:,
        page_path: result["path"],
        feedex_comments: result["count"],
      }
    end
  end
end
