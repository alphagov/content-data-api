require 'csv'

# For example:
# https://docs.google.com/spreadsheets/d/1Z042QNKIxB8ZSnKaPuYSCNBjJfXTx7Z4_qmVR30cBEs/pub?gid=2031568164&single=true&output=csv
class RemoteCsv
  def initialize(csv_url)
    @csv_url = csv_url
  end

  def each_row
    parsed_data.each do |row|
      yield(row)
    end
  end

private

  def parsed_data
    CSV.parse(sheet_data, headers: true)
  end

  def sheet_data
    response.body
  end

  def response
    @_response ||= Net::HTTP.get_response(URI(@csv_url))
  end
end
