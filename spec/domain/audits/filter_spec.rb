module Audits
  RSpec.describe Filter do
    context 'with sort criteria' do
      subject { described_class.new(sort: 'foo', sort_direction: 'asc') }

      it { is_expected.to have_attributes(sort_by: 'foo_asc') }
    end
  end
end
