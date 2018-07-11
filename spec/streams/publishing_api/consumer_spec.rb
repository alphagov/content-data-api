RSpec.describe PublishingAPI::Consumer do
  describe '#process' do
    describe 'event tracking coming from PublishingAPI' do
      before { allow(PublishingAPI::MessageHandler).to receive(:process) }

      it 'stores all the events' do
        expect {
          subject.process(build(:message))
          subject.process(build(:message))
        }.to change(PublishingApiEvent, :count).by(2)
      end

      it 'does not check for duplicities' do
        expect {
          message = build :message

          subject.process(message)
          subject.process(message)
        }.to change(PublishingApiEvent, :count).by(2)
      end
    end
  end
end
