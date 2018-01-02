require 'rails_helper'

RSpec.describe Dimensions::Organisation, type: :model do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_presence_of(:link) }
  it { is_expected.to validate_presence_of(:content_id) }
  it { is_expected.to validate_presence_of(:state) }
end
