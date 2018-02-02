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

  describe 'with zero pageviews and zero unique pageviews' do
    subject { build(:facts_metric, pageviews: 0, unique_pageviews: 0) }

    it { is_expected.to be_valid }
  end

  describe 'with zero pageviews but unique pageviews' do
    subject { build(:facts_metric, pageviews: 0, unique_pageviews: 1) }

    it { is_expected.not_to be_valid }
  end

  describe 'with pageviews but zero unique pageviews' do
    subject { build(:facts_metric, pageviews: 1, unique_pageviews: 0) }

    it { is_expected.not_to be_valid }
  end

  describe 'with more pageviews than unique pageviews' do
    subject { build(:facts_metric, pageviews: 2, unique_pageviews: 1) }

    it { is_expected.to be_valid }
  end

  describe 'with more unique pageviews than pageviews' do
    subject { build(:facts_metric, pageviews: 1, unique_pageviews: 2) }

    it { is_expected.not_to be_valid }
  end

  describe 'with pageviews but non-existent unique pageviews' do
    subject { build(:facts_metric, pageviews: 1, unique_pageviews: nil) }

    it { is_expected.not_to be_valid }
  end

  describe 'with non-existent pageviews but unique pageviews' do
    subject { build(:facts_metric, pageviews: nil, unique_pageviews: 1) }

    it { is_expected.not_to be_valid }
  end
end
