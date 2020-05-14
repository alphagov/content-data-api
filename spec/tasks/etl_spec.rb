RSpec.describe "etl.rake", type: task do
  before do
    allow($stdout).to receive(:puts)
  end

  describe "rake etl:master"
  it "calls Etl::Master::MasterProcessor.process" do
    processor = class_double(Etl::Master::MasterProcessor, process: true).as_stubbed_const

    expect(processor).to receive(:process)

    Rake::Task["etl:master"].invoke
  end

  describe "rake etl:repopulate_aggregations_month" do
    it "calls Etl::Aggregations::Monthly with each date" do
      processor = class_double(Etl::Aggregations::Monthly, process: true).as_stubbed_const

      Rake::Task["etl:repopulate_aggregations_month"].invoke("2018-11-01", "2019-01-03")

      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 1))
      expect(processor).to have_received(:process).with(date: Date.new(2018, 12, 1))
      expect(processor).to have_received(:process).with(date: Date.new(2019, 1, 1))
    end
  end

  describe "rake etl:repopulate_aggregations_search" do
    it "calls Etl::Aggregations::Search" do
      processor = class_double(Etl::Aggregations::Search, process: true).as_stubbed_const

      Rake::Task["etl:repopulate_aggregations_search"].invoke

      expect(processor).to have_received(:process)
    end
  end

  describe "rake etl:repopulateviews" do
    it "calls Etl::GA::ViewsAndNavigationProcessor with each date" do
      processor = class_double(Etl::GA::ViewsAndNavigationProcessor, process: true).as_stubbed_const

      Rake::Task["etl:repopulateviews"].invoke("2018-11-01", "2018-11-03")

      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 1))
      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 2))
      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 3))
    end
  end

  describe "rake etl:repopulate_searches" do
    it "calls Etl::GA::InternalSearchProcessor with each date" do
      processor = class_double(Etl::GA::InternalSearchProcessor, process: true).as_stubbed_const

      Rake::Task["etl:repopulate_searches"].invoke("2018-11-01", "2018-11-03")

      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 1))
      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 2))
      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 3))
    end
  end

  describe "rake etl:repopulate_useful" do
    it "calls Etl::GA::UserFeedbackProcessor.process with each date" do
      processor = class_double(Etl::GA::UserFeedbackProcessor, process: true).as_stubbed_const

      Rake::Task["etl:repopulate_useful"].invoke("2018-11-01", "2018-11-03")

      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 1))
      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 2))
      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 3))
    end
  end

  describe "rake etl:repopulate_feedex" do
    it "calls Etl::Feedex::Processor.process with each date" do
      processor = class_double(Etl::Feedex::Processor, process: true).as_stubbed_const

      Rake::Task["etl:repopulate_feedex"].invoke("2018-11-01", "2018-11-03")

      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 1))
      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 2))
      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 3))
    end
  end

  describe "rake etl:rerun_master" do
    let!(:processor) do
      class_double(
        Etl::Master::MasterProcessor,
        process: true,
        process_aggregations: true,
      ).as_stubbed_const
    end

    before do
      edition = create :edition, date: "2018-10-03"
      create :metric, edition: edition, date: "2018-10-30"
      create :metric, edition: edition, date: "2018-10-31"
      create :metric, edition: edition, date: "2018-11-01"
      create :metric, edition: edition, date: "2018-11-02"
      create :metric, edition: edition, date: "2018-11-03"
      Rake::Task["etl:rerun_master"].reenable
      Rake::Task["etl:rerun_master"].invoke("2018-10-31", "2018-11-02")
    end

    it "calls Etl::Master::MasterProcessor.process with each date" do
      [Date.new(2018, 10, 31), Date.new(2018, 11, 1), Date.new(2018, 11, 2)].each do |date|
        expect(processor).to have_received(:process).once.with(date: date)
      end
    end

    it "runs the aggregations process for each month in the range" do
      [Date.new(2018, 10, 31), Date.new(2018, 11, 30)].each do |date|
        expect(processor).to have_received(:process_aggregations).once.with(date: date)
      end
    end
  end
end
