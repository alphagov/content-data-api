RSpec.shared_examples 'BaseMessage#historically_political?' do
  describe '#historically_political?' do
    let(:payload) { build(:message).payload }
    let(:message) { described_class.new(payload) }
    subject { message.historically_political? }

    context 'when payload has current goverment as false and has political as true' do
      before {
        payload['details']['political'] = true
        payload['details']['government']['current'] = false
      }
      it { is_expected.to eq true }
    end

    context 'when payload has no political information' do
      before { payload['details'].delete('political') }

      it { is_expected.to eq false }
    end

    context 'when payload has political as false' do
      before { payload['details']['political'] = false }
      it { is_expected.to eq false }
    end

    context 'when payload has no goverment information' do
      before { payload['details'].delete('government') }
      it { is_expected.to eq false }
    end

    context 'when payload has current goverment as true' do
      before { payload['details']['government']['current'] = true }
      it { is_expected.to eq false }
    end
  end
end

RSpec.shared_examples 'BaseMessage#withdrawn_notice?' do
  describe '#withdrawn_notice?' do
    let(:payload) { build(:message).payload }
    let(:message) { described_class.new(payload) }
    subject { message.withdrawn_notice? }

    context 'when payload has withdrawn notice with explanation' do
      before { payload['withdrawn_notice'] = { explanation: 'Not relevant' } }
      it { is_expected.to eq true }
    end

    context 'when payload has no withdrawn notice information' do
      before { payload.delete('withdrawn_notice') }
      it { is_expected.to eq false }
    end
  end
end
