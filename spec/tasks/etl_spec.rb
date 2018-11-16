RSpec.describe 'etl.rake', type: task do
  describe 'rake etl:master'
  it "calls Etl::Master::MasterProcessor.process" do
    processor = class_double(Etl::Master::MasterProcessor, process: true).as_stubbed_const
    expect(processor).to receive(:process)

    Rake::Task['etl:master'].invoke
  end

  describe 'rake etl:repopulateviews' do
    it 'calls Etl::GA::ViewsAndNavigationProcessor with each date' do
      processor = class_double(Etl::GA::ViewsAndNavigationProcessor, process: true).as_stubbed_const
      Rake::Task['etl:repopulateviews'].invoke('2018-11-01', '2018-11-03')
      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 1))
      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 2))
      expect(processor).to have_received(:process).with(date: Date.new(2018, 11, 3))
    end
  end

  describe 'rake etl:rerun_master' do
    let!(:processor) { class_double(Etl::Master::MasterProcessor, process: true).as_stubbed_const }
    before do
      edition = create :edition, date: '2018-11-01'
      create :metric, edition: edition, date: '2018-11-02'
      create :metric, edition: edition, date: '2018-11-03'
      create :metric, edition: edition, date: '2018-11-06'
    end

    it 'calls Etl::Master::MasterProcessor.process with each date after deleting existing metrics' do
      Rake::Task['etl:rerun_master'].invoke('2018-11-03', '2018-11-05')
      [Date.new(2018, 11, 3), Date.new(2018, 11, 4), Date.new(2018, 11, 5)].each do |date|
        expect(processor).to have_received(:process).with(date: date)
      end
      expect(Facts::Metric.pluck(:dimensions_date_id)).to eq([Date.new(2018, 11, 2), Date.new(2018, 11, 6)])
    end
  end
end
