module Audits
  RSpec.describe Policies::Passed do
    subject(:passed) { described_class.call(scope) }

    let(:passed_audits) { create_list(:passing_audit, 2) }
    let(:failed_audits) { create_list(:failing_audit, 2) }
    let(:scope) { Content::Item.all }

    it 'returns content items that passed an audit' do
      expect(passed).to match_array(passed_audits.collect(&:content_item))
    end
  end
end
