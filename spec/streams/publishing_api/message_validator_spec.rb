RSpec.describe PublishingAPI::MessageValidator do
  subject { described_class }

  describe '.is_old_message?' do
    it 'does not throw an exception when receiving message without locale' do
      message = build(:message)
      message.payload.except!('locale')

      expect { subject.is_old_message?(message) }.not_to raise_error
    end
  end
end
