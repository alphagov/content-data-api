require 'rails_helper'

RSpec.describe Aggregations::MonthlyMetric, type: :model do
  it { is_expected.to validate_presence_of(:dimensions_month) }
  it { is_expected.to validate_presence_of(:dimensions_edition) }
end
