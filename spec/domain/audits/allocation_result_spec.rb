module Audits
  RSpec.describe AllocationResult do
    subject(:allocation_result) { described_class.new(user, count) }

    let(:user) { 'Joe Bloggs' }

    context 'with a count of zero' do
      let(:count) { 0 }

      it { is_expected.not_to be_success }
      it { is_expected.to have_attributes(message: 'You did not select any content to be assigned') }
    end

    context 'with a count of one' do
      let(:count) { 1 }

      it { is_expected.to be_success }
      it { is_expected.to have_attributes(message: '1 item assigned to Joe Bloggs') }
    end

    context 'with a count greater than one' do
      let(:count) { 10 }

      it { is_expected.to be_success }
      it { is_expected.to have_attributes(message: '10 items assigned to Joe Bloggs') }
    end
  end
end
