require 'gds-api-adapters'
require 'traceable'

RSpec.describe Etl::GA::UserFeedbackProcessor do
  include ItemSetupHelpers
  subject { described_class }

  let(:date) { Date.new(2018, 2, 20) }

  context 'When the base_path matches the GA path' do
    before { allow(Etl::GA::UserFeedbackService).to receive(:find_in_batches).and_yield(ga_response) }

    it 'update the facts with the GA metrics' do
      fact1 = create_metric base_path: '/path1', date: '2018-02-20', daily: { is_this_useful_no: 1, is_this_useful_yes: 2 }
      fact2 = create_metric base_path: '/path2', date: '2018-02-20', daily: { is_this_useful_no: 20, is_this_useful_yes: 10 }

      expect(fact1).to have_attributes(is_this_useful_no: 1, is_this_useful_yes: 2)
      expect(fact2).to have_attributes(is_this_useful_no: 20, is_this_useful_yes: 10)

      described_class.process(date: date)

      expect(fact1.reload).to have_attributes(is_this_useful_no: 1, is_this_useful_yes: 1)
      expect(fact1.satisfaction_score).to be_within(0.1).of(0.5)
      expect(fact2.reload).to have_attributes(is_this_useful_no: 5, is_this_useful_yes: 10)
      expect(fact2.satisfaction_score).to be_within(0.1).of(0.67)
    end

    it 'does not update metrics for other days' do
      fact1 = create_metric base_path: '/path1', date: '2018-02-20',
        daily: { is_this_useful_no: 20, is_this_useful_yes: 10 }

      day_before = date - 1
      described_class.process(date: day_before)

      expect(fact1.reload).to have_attributes(is_this_useful_no: 20, is_this_useful_yes: 10)
    end

    it 'does not update metrics for other items' do
      fact = create_metric base_path: '/non-matching-path', date: '2018-02-20',
        daily: { is_this_useful_no: 99, is_this_useful_yes: 90 }

      described_class.process(date: date)

      expect(fact.reload).to have_attributes(is_this_useful_no: 99, is_this_useful_yes: 90)
    end

    it "deletes events after updating facts metrics" do
      create(:ga_event, :with_user_feedback, date: date - 1, page_path: '/path1')

      described_class.process(date: date)

      expect(Events::GA.count).to eq(0)
    end

    context 'when there are events from other days' do
      before do
        create(:ga_event, :with_user_feedback, date: date - 1, page_path: '/path1')
        create(:ga_event, :with_user_feedback, date: date - 2, page_path: '/path1')
      end

      it 'only updates metrics for the current day' do
        fact1 = create_metric base_path: '/path1', date: '2018-02-20'

        described_class.process(date: date)

        expect(fact1.reload).to have_attributes(is_this_useful_no: 1, is_this_useful_yes: 1)
      end
    end
  end

  context 'When is_this_useful values are received from GA' do
    let!(:fact) { create_metric base_path: '/path1', date: '2018-02-20' }

    it 'sets `satisfaction_score = 1.0` with `yes: 1` and `no: 0`' do
      allow(Etl::GA::UserFeedbackService).to receive(:find_in_batches).and_yield(ga_response(useful_yes: 1, useful_no: 0))
      described_class.process(date: date)

      expect(fact.reload.satisfaction_score).to be_within(0.1).of(1.0)
    end

    it 'sets `satisfaction_score = 0.0` with `useful_yes:0` and `no: 1`' do
      allow(Etl::GA::UserFeedbackService).to receive(:find_in_batches).and_yield(ga_response(useful_yes: 0, useful_no: 1))
      described_class.process(date: date)

      expect(fact.reload.satisfaction_score).to be_within(0.1).of(0.0)
    end
  end

private

  def ga_response(useful_yes: 1, useful_no: 1)
    [
      {
        'page_path' => '/path1',
        'is_this_useful_yes' => useful_yes,
        'is_this_useful_no' => useful_no,
        'date' => '2018-02-20',
        'process_name' => 'user_feedback',
      },
      {
        'page_path' => '/path2',
        'is_this_useful_no' => 5,
        'is_this_useful_yes' => 10,
        'date' => '2018-02-20',
        'process_name' => 'user_feedback',
      },
    ]
  end
end
