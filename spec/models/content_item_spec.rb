require 'rails_helper'

RSpec.describe ContentItem, type: :model do
  it { should belong_to(:organisation) }
end
