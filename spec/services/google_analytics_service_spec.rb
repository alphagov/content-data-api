require 'rails_helper'

RSpec.describe GoogleAnalyticsService do
  subject { GoogleAnalyticsService.new }

  describe "#page_views" do
    it "raises an exception when another type is supplied, instead of an Array" do
      expect { subject.page_views("/marriage-abroad") }.to raise_error("base_paths isn't an array")
    end
  end
end
