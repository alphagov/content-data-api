module Audits
  RSpec.describe Policies::NonAudited do
    subject(:non_audited) { described_class.call(scope) }

    let(:content_items) { create_list(:content_item, 2) }
    let(:audits) { create_list(:audit, 2) }
    let(:scope) { Content::Item.all }

    it 'returns a non audited scope' do
      expect(non_audited).to match_array(content_items)
    end
  end
end
