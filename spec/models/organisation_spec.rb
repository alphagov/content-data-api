require 'rails_helper'

RSpec.describe Organisation, type: :model do
  it { should have_many(:content_items) }
end
