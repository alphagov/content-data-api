module Audits
  RSpec.describe Policies::NoPolicy do
    subject(:no_policy) { described_class.call(scope) }

    let(:scope) { Content::Item.all }

    it 'returns an unmodified scope' do
      expect(no_policy).to match_array(scope)
    end
  end
end
