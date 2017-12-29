require 'rails_helper'

RSpec.describe Facts::Metric, type: :model do
  it { is_expected.to validate_presence_of(:dimensions_date) }
  it { is_expected.to validate_presence_of(:dimensions_item) }
  it { is_expected.to validate_presence_of(:dimensions_organisation) }
end
