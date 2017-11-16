module Audits
  RSpec.describe Policies::Audited do
    subject(:audited) { described_class.call(scope) }

    let(:allocations) { create_list(:allocation, 2) }
    let(:audits) { create_list(:audit, 2) }
    let(:scope) { Content::Item.all }

    it 'returns an audited scope' do
      expect(audited).to match_array(audits.collect(&:content_item))
    end
  end
end
