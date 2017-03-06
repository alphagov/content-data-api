require "rails_helper"

RSpec.describe MetricBuilder do
  describe "#run_all" do
    let(:metrics) { { m1: 1 } }

    it "calls each metric class once" do
      expect_any_instance_of(Metrics::NumberOfPdfsMetric).to receive(:run).exactly(1).times

      subject.run_all({})
    end
  end
end
