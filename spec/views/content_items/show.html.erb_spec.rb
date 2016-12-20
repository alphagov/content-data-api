require 'rails_helper'

RSpec.describe 'content_items/show.html.erb', type: :view do
  let(:content_item) { build(:content_item) }

  before do
    assign(:content_item, content_item)
  end

  it 'renders the title' do
    content_item.title = 'A Title'
    render

    expect(rendered).to have_selector('h1', text: 'A Title')
  end

  it 'renders the url' do
    content_item.link = '/content/1/path'
    render

    expect(rendered).to have_link("Page on GOV.UK", href: 'https://gov.uk/content/1/path')
  end

  xit 'renders the document type'

  xit 'renders the last updated date'
end
