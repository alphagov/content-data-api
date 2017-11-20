module Audits
  RSpec.describe Policies::Failed do
    subject(:failed) { described_class.call(scope) }

    let(:audits) { create_list(:audit, 2) }
    let(:failed_audits) { create_list(:failing_audit, 2) }
    let(:scope) { Content::Item.all }

    it 'returns content items that failed an audit' do
      expect(failed).to match_array(failed_audits.collect(&:content_item))
    end
  end
end
