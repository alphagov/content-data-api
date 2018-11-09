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
end
