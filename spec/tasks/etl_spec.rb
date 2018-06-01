
RSpec.describe 'rake etl:master', type: task do
  it "calls Master::MasterProcessor.process" do
    processor = class_double(Master::MasterProcessor, process: true).as_stubbed_const
    expect(processor).to receive(:process)

    Rake::Task['etl:master'].invoke
  end
end
