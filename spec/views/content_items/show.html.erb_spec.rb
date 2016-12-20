require 'rails_helper'

RSpec.describe 'content_items/show.html.erb', type: :view do
  let(:content_item) { build(:content_item) }

  it 'renders the title of the content item' do
    content_item.title = 'A Title'
    assign(:content_item, content_item)
    render

    expect(rendered).to have_selector('h1', text: 'A Title')
  end

  xit 'renders the url of the content item'

  xit 'renders the document type of the content item'

  xit 'renders the last updated date of the content item'
end
