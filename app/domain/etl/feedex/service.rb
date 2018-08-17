require 'gds_api/support_api'

class Etl::Feedex::Service
  attr_reader :date, :batch_size, :support_api

  def initialize(date, batch_size, support_api = nil)
    @date = date
    @batch_size = batch_size
    @support_api = support_api || support_api_with_long_timeout
  end

  def find_in_batches
    current_page = 1
    loop do
      response = support_api.feedback_by_day(date, current_page, @batch_size)
      yield convert_results(response['results'])

      break if response['pages'] == current_page
      current_page += 1
    end
  end

private

  def support_api_with_long_timeout
    GdsApi::SupportApi.new(Plek.new.find('support-api')).tap do |client|
      client.options[:timeout] = 15
    end
  end

  def convert_results(results)
    results.map do |result|
      {
        date: date,
        page_path: result['path'],
        feedex_comments: result['count']
      }
    end
  end
end
