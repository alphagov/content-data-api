require 'rails_helper'

RSpec.describe Dimensions::Item, type: :model do
  it { is_expected.to validate_presence_of(:content_id) }
end
