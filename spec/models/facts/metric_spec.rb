require 'rails_helper'

RSpec.describe Facts::Metric, type: :model do
  it { is_expected.to validate_presence_of(:dimensions_date) }
  it { is_expected.to validate_presence_of(:dimensions_item) }

  specify do
    is_expected.to validate_numericality_of(:pageviews)
                     .only_integer
                     .allow_nil
  end

  specify do
    is_expected.to validate_numericality_of(:unique_pageviews)
                     .only_integer
                     .allow_nil
  end
end
