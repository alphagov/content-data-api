require 'odyssey'

RSpec.describe ContentQualityService do
  let(:content) { 'Some content the has the oddd spelling mistkae' }

  it 'makes request and outputs the results' do
    allow(subject).to receive(:fetch).with(content).and_return(
      'spell' => {
        'count' => 2
      },
      'simplify' => {
        'count' => 1
      }
    )
    expect(subject.run(content)).to include(
      spell_count: 2,
      simplify_count: 1,
      equality_count: 0,
    )
  end

  it 'calculates the reading age' do
    allow(subject).to receive(:fetch).with(content).and_return({})

    expect(subject.run(content)).to include(
      readability_score: 82.4,
    )
  end
end
