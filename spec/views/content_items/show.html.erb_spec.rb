require 'rails_helper'

RSpec.describe 'content_items/show.html.erb', type: :view do
  let(:content_item) { build(:content_item) }
  let(:organisation) { build(:organisation) }

  before do
    assign(:content_item, content_item)
    assign(:organisation, organisation)
  end

  it 'renders the title' do
    content_item.title = 'A Title'
    render

    expect(rendered).to have_selector('h1', text: 'A Title')
  end

  it 'renders the url' do
    content_item.base_path = '/content/1/path'
    render

    expect(rendered).to have_text('Page on GOV.UK')
    expect(rendered).to have_link('https://gov.uk/content/1/path', href: 'https://gov.uk/content/1/path')
  end

  it 'renders the document type' do
    content_item.document_type = 'guidance'
    render

    expect(rendered).to have_text('Document type')
    expect(rendered).to have_text('guidance')
  end

  it 'renders the last updated date' do
    Timecop.freeze('2016-3-20') do
      content_item.public_updated_at = Date.parse('2016-1-20')
      render
    end

    expect(rendered).to have_text('Last updated')
    expect(rendered).to have_text('2 months ago')
  end

  it 'renders the organisation name' do
    organisation.title = 'An Organisation'
    render

    expect(rendered).to have_text('Organisation')
    expect(rendered).to have_text('An Organisation')
  end

  it 'renders the description of the content item' do
    content_item.description = 'The description of a content item'
    render

    expect(rendered).to have_text('Description')
    expect(rendered).to have_text('The description of a content item')
  end
end
