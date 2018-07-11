require 'rails_helper'

RSpec.describe PublishingApiEvent, type: :model do
  it { is_expected.to validate_presence_of(:payload) }
  it { is_expected.to validate_presence_of(:routing_key) }
end
