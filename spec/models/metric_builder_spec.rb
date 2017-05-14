require "rails_helper"

RSpec.describe MetricBuilder do
  describe "#run_all" do
    let(:metrics) { { m1: 1 } }

    it "calls each metric class once" do
      expect_any_instance_of(Metrics::NumberOfPdfs).to receive(:run).exactly(1).times

      subject.run_all({})
    end
  end

  describe "#run_collection" do
    it "calls each collection metric class once" do
      expect_any_instance_of(Metrics::TotalPages).to receive(:run).exactly(1).times.and_return({})
      expect_any_instance_of(Metrics::ZeroPageViews).to receive(:run).exactly(1).times.and_return({})
      expect_any_instance_of(Metrics::PagesNotUpdated).to receive(:run).exactly(1).times.and_return({})
      expect_any_instance_of(Metrics::PagesWithPdfs).to receive(:run).exactly(1).times.and_return({})

      subject.run_collection([])
    end
  end
end
