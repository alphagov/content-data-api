RSpec.describe 'rake etl:populate_content' do
  let!(:item_without_content) do
    create :dimensions_item, base_path: '/without', document_text: nil, raw_json: build_json(body: '<p>new content</p>')
  end
  let!(:item_with_content) do
    create :dimensions_item, base_path: '/with', document_text: 'existing content', raw_json: build_json(body: '<p>new content</p>')
  end

  before do
    Rake::Task['etl:populate_content'].invoke
  end

  it 'updates the content where it is missing' do
    expect(item_without_content.reload.document_text).to eq('new content')
  end

  it 'ignores items with existing content' do
    expect(item_with_content.reload.document_text).to eq('existing content')
  end

  def build_json(body:)
    {
      schema_name: 'news_article',
      details: {
        body: body
      }
    }
  end
end
