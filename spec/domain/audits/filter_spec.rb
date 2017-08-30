module Audits
  RSpec.describe Audits::Filter do
    it { is_expected.to have_attributes(sort: nil, sort_direction: nil) }

    context "sorting by 'foo' ascending" do
      subject { described_class.new(sort_by: 'foo_asc') }

      it { is_expected.to have_attributes(sort: 'foo', sort_direction: 'asc') }
    end

    context "sorting by 'invalid_value'" do
      subject { -> { described_class.new(sort_by: 'an_invalid_value') } }

      it { is_expected.to raise_error("Invalid value: an_invalid_value") }
    end
  end
end
