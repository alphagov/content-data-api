RSpec.describe TermGeneration::TaxonomyProjectBuilder do
  before :each do
    @url = 'http://www.example.com/my_csv'
    csv =
      <<~EOCSV
        content_id
        xxx
        yyy
    EOCSV

    ContentItem.create(content_id: 'xxx')
    ContentItem.create(content_id: 'yyy')
    stub_request(:get, @url).to_return(body: csv)
  end

  it 'creates a new project' do
    expect { TermGeneration::TaxonomyProjectBuilder.build(name: 'test', csv_url: @url) }.to change { TaxonomyProject.count }.by(1)
  end

  it 'imports the csv file into the new project' do
    project = TermGeneration::TaxonomyProjectBuilder.build(name: 'test', csv_url: @url)
    expect(project.reload.taxonomy_todos.map(&:content_item).map(&:content_id)).to match_array(%w(xxx yyy))
  end
end
