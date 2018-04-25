RSpec.shared_examples "transform path examples" do
  it 'removes the "/https://www.gov.uk" from the GA::Event page_path' do
    subject.process(date: date)
    expect(Events::GA.where(page_path: '/https://gov.uk/path1').count).to eq 0
    expect(Events::GA.where(page_path: '/path1').count).to eq 1
  end
end
