require 'rails_helper'

RSpec.describe Organisation, type: :model do
  it { should have_and_belong_to_many(:content_items) }
end
