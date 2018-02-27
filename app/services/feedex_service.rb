class FeedexService
  attr_reader :batch_size, :support_api
  def initialize(batch_size, support_api = GdsApi::SupportApi.new(Plek.new.find('support-api')))
    @batch_size = batch_size
    @support_api = support_api
  end

  def find_in_batches(date)
    first_page = support_api.feedback_by_day(date, 1, @batch_size)
    yield convert_results(first_page['results'], date)
    no_of_pages = first_page['pages']
    return if no_of_pages == 1
    (2..no_of_pages).each do |p|
      page = support_api.feedback_by_day(date, p, @batch_size)
      yield convert_results(page['results'], date)
    end
  end

private

  def convert_results(data, date)
    data.map do |d|
      {
        date: date,
        page_path: d['path'],
        number_of_issues: d['count']
      }
    end
  end
end
