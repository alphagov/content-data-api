RSpec.describe ContentQualityService do
  let(:content) { 'Some content the has the oddd spelling mistkae' }

  it 'makes request and outputs the results' do
    allow(subject).to receive(:fetch).with(content).and_return(
      'spell' => {
        'count' => 2
      },
      'readability' => {
        'count' => 1
      }
    )
    expect(subject.run(content)).to include(
      spell_count: 2,
      readability_count: 1,
      equality_count: 0,
    )
  end
end
