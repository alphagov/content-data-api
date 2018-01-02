require 'rails_helper'

RSpec.describe Dimensions::Organisation, type: :model do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_presence_of(:link) }
  it { is_expected.to validate_presence_of(:content_id) }
  it { is_expected.to validate_presence_of(:state) }
  it { should validate_uniqueness_of(:title).scoped_to(:slug, :link, :content_id, :state) }
end
