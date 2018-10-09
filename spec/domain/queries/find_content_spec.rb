RSpec.describe Queries::FindContent do
  let(:primary_org_id) { '96cad973-92dc-41ea-a0ff-c377908fee74' }
  let(:warehouse_item_id) { '87d87ac6-e5b5-4065-a8b5-b7a43db648d2' }
  let(:another_warehouse_item_id) { 'ebf0dd2f-9d99-48e3-84d0-e94a2108ef45' }

  before do
    create :user
  end

  context 'metrics on multiple days' do
    before do
      edition = create :edition,
        base_path: '/path/1',
        date: '2018-01-01',
        title: 'item 1 title',
        document_type: 'news_story',
        organisation_id: primary_org_id,
        warehouse_item_id: warehouse_item_id
      create :metric,
        edition: edition,
        date: '2018-01-01',
        upviews: 100,
        useful_yes: 50,
        useful_no: 20,
        searches: 20
      create :metric,
        edition: edition,
        date: '2018-01-02',
        upviews: 133,
        useful_yes: 150,
        useful_no: 30,
        searches: 200

      other_edition = create :edition,
        base_path: '/path/2',
        date: '2018-01-01',
        title: 'item 2 title',
        document_type: 'press_release',
        organisation_id: primary_org_id,
        warehouse_item_id: another_warehouse_item_id
      create :metric,
        edition: other_edition,
        date: '2018-01-01',
        upviews: 5,
        useful_yes: 5,
        useful_no: 4,
        searches: 4
      create :metric,
        edition: other_edition,
        date: '2018-01-02',
        upviews: 15,
        useful_yes: 5,
        useful_no: 6,
        searches: 3
    end

    it 'aggregates the data by content item' do
      results = described_class.retrieve(from: '2018-01-01', to: '2018-02-01', organisation_id: primary_org_id)
      expect(results).to eq(
        [
          {
            base_path: '/path/1',
            title: 'item 1 title',
            upviews: 233,
            document_type: 'news_story',
            satisfaction: 0.8,
            satisfaction_score_responses: 250,
            searches: 220
          },
          {
            base_path: '/path/2',
            title: 'item 2 title',
            upviews: 20,
            document_type: 'press_release',
            satisfaction: 0.5,
            satisfaction_score_responses: 20,
            searches: 7
          }
        ]
      )
    end
  end

  context 'the attributes we are displaying have changed over time' do
    before do
      old_edition = create :edition,
        base_path: '/old/base/path',
        date: '2018-01-01',
        title: 'old title',
        document_type: 'news_story',
        organisation_id: primary_org_id,
        latest: false,
        warehouse_item_id: warehouse_item_id
      create :metric,
        edition: old_edition,
        date: '2018-01-02',
        upviews: 100,
        useful_yes: 10,
        useful_no: 10,
        searches: 15
      new_edition = create :edition,
        replaces: old_edition,
        base_path: '/new/base/path',
        date: '2018-01-02',
        title: 'new title',
        document_type: 'press_release',
        organisation_id: primary_org_id
      create :metric,
        edition: new_edition,
        date: '2018-01-02',
        upviews: 100,
        useful_yes: 50,
        useful_no: 50,
        searches: 5
    end

    it 'returns aggregated metrics from all versions with metadata from the latest version' do
      results = described_class.retrieve(from: '2018-01-01', to: '2018-02-01', organisation_id: primary_org_id)
      expect(results.count).to eq(1)
      expect(results.first).to eq(
        base_path: '/new/base/path',
        title: 'new title',
        upviews: 200,
        document_type: 'press_release',
        satisfaction: 0.5,
        satisfaction_score_responses: 120,
        searches: 20
      )
    end
  end

  context 'when no useful_yes/no.. responses' do
    before do
      edition = create :edition,
        date: '2018-01-01',
        organisation_id: primary_org_id
      create :metric,
             edition: edition,
             date: '2018-01-01',
             useful_yes: 0,
             useful_no: 0
    end

    it 'returns the nil for the satisfaction' do
      results = described_class.retrieve(from: '2018-01-01', to: '2018-02-01', organisation_id: primary_org_id)
      expect(results.first).to include(
        satisfaction: nil,
        satisfaction_score_responses: 0
      )
    end
  end

  context 'when no metrics in the date range' do
    before do
      create :edition, date: '2018-02-01'
    end

    it 'returns a empty array' do
      results = described_class.retrieve(from: '2018-02-01', to: '2018-02-02', organisation_id: primary_org_id)
      expect(results).to be_empty
    end
  end

  context 'when no items exist for the organisation' do
    it 'returns a empty array' do
      results = described_class.retrieve(from: '2018-02-01', to: '2018-02-02', organisation_id: primary_org_id)
      expect(results).to be_empty
    end
  end
end
