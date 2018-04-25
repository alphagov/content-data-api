RSpec.shared_examples "transform path examples" do
  it 'removes the "/https://www.gov.uk" from the GA::Event page_path' do
    subject.process(date: date)
    expect(Events::GA.where(page_path: '/https://gov.uk/path1').count).to eq 0
    expect(Events::GA.where(page_path: '/path1').count).to eq 1
  end

  def ga_response_with_govuk_prefix
    [
      {
        'page_path' => '/https://www.gov.uk/path1',
        'is_this_useful_no' => 1,
        'is_this_useful_yes' => 1,
        'date' => '2018-02-20',
      },
      {
        'page_path' => '/path2',
        'is_this_useful_no' => 5,
        'is_this_useful_yes' => 10,
        'date' => '2018-02-20',
      },
    ]
  end
end
