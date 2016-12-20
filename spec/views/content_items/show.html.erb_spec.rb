require 'rails_helper'

RSpec.describe 'content_items/show.html.erb', type: :view do
  let(:content_item) { build(:content_item) }

  it 'renders the title' do
    content_item.title = 'A Title'
    assign(:content_item, content_item)
    render

    expect(rendered).to have_selector('h1', text: 'A Title')
  end

  xit 'renders the url'

  xit 'renders the document type'

  xit 'renders the last updated date'
end
