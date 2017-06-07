require 'rails_helper'

RSpec.describe RemoteCsv do
  subject { described_class.new(csv_url) }

  let(:csv_url) { 'http://www.example.com/my_csv' }
  let(:csv) do
    <<~EOCSV
      content_id
      xxx
      yyy
    EOCSV
  end

  before do
    stub_request(:get, csv_url).to_return(body: csv)
  end

  describe "#each_row" do
    it "yields for each row of the CSV" do
      result = []
      callback = Proc.new { |row| result << row['content_id'] }
      subject.each_row(&callback)
      expect(result).to eql %w(xxx yyy)
    end
  end
end
