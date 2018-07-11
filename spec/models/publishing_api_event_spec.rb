require 'rails_helper'

RSpec.describe PublishingApiEvent, type: :model do
  it { is_expected.to validate_presence_of(:payload) }
  it { is_expected.to validate_presence_of(:routing_key) }

  describe 'is_link_update?' do
    it 'returns true if ends with `.links`' do
      event = build :publishing_api_event, :link_update

      expect(event.is_links_update?).to be true
    end

    it 'returns false otherwise' do
      event = build :publishing_api_event, :major_update

      expect(event.is_links_update?).to be false
    end
  end
end
