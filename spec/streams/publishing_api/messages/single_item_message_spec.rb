RSpec.describe PublishingAPI::Messages::SingleItemMessage do
  subject { described_class }
  include_examples 'BaseMessage#historically_political?'
  include_examples 'BaseMessage#withdrawn_notice?'
end
