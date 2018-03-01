require 'gds_api/support_api'

RSpec.describe FeedexService do
  let(:support_api) { double('support_api') }
  let(:subject) { described_class.new(date, 20, support_api) }

  describe '#find_in_batches' do
    let(:date) { Date.new(2018, 2, 1) }
    let(:response_1) do
      {
        'results' => [
          { 'path' => '/path/1', 'count' => 3 },
          { 'path' => '/path/2', 'count' => 1 }
        ],
        'pages' => 3,
        'current_page' => 1
      }
    end
    let(:response_2) do
      {
        'results' => [
          { 'path' => '/path/3', 'count' => 5 },
          { 'path' => '/path/4', 'count' => 2 }
        ],
        'pages' => 3,
        'current_page' => 2
      }
    end
    let(:response_3) do
      {
        'results' => [
          { 'path' => '/path/5', 'count' => 1 },
          { 'path' => '/path/6', 'count' => 7 }
        ],
        'pages' => 3,
        'current_page' => 3
      }
    end

    before :each do
      allow(support_api).to receive(:feedback_by_day)
        .with(date, 1, 20).and_return(response_1)
      allow(support_api).to receive(:feedback_by_day)
        .with(date, 2, 20).and_return(response_2)
      allow(support_api).to receive(:feedback_by_day)
        .with(date, 3, 20).and_return(response_3)
    end

    it 'makes the correct request and yields the first page' do
      expected_date = Date.parse('01/02/2018')

      expect { |b| subject.find_in_batches(&b) }.to yield_successive_args(
        [
          {
            date: expected_date,
            page_path: '/path/1',
            number_of_issues: 3
          },
          {
            date: expected_date,
            page_path: '/path/2',
            number_of_issues: 1
          }
        ],
        [
          {
            date: expected_date,
            page_path: '/path/3',
            number_of_issues: 5
          },
          {
            date: expected_date,
            page_path: '/path/4',
            number_of_issues: 2
          }
        ],
        [
          {
            date: expected_date,
            page_path: '/path/5',
            number_of_issues: 1
          },
          {
            date: expected_date,
            page_path: '/path/6',
            number_of_issues: 7
          }
        ]

      )

      expect(support_api).to have_received(:feedback_by_day).with(expected_date, 1, 20)
      expect(support_api).to have_received(:feedback_by_day).with(expected_date, 2, 20)
      expect(support_api).to have_received(:feedback_by_day).with(expected_date, 3, 20)
      expect(support_api).not_to have_received(:feedback_by_day).with(expected_date, 4, 20)
    end
  end
end
