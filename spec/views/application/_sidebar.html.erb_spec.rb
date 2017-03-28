require 'rails_helper'

RSpec.describe 'application/_sidebar.html.erb', type: :view do
  before do
    assign(:organisations, [])
    assign(:taxonomies, [])
  end

  context "filtering organisations" do
    it "renders a select box with the existing organisations including the `empty` option" do
      organisations = [build(:organisation, title: "title 1"), build(:organisation, title: "title 2")]
      assign(:organisations, organisations)

      render

      expect(rendered).to have_select(:organisation_id, options: ["", "title 1", "title 2"])
    end
  end

  context "filtering by taxonomies" do
    it "renders a select box with the existing taxonomies including the `empty` option" do
      taxonomies = [build(:taxonomy, title: "title 1"), build(:taxonomy, title: "title 2")]
      assign(:taxonomies, taxonomies)

      render

      expect(rendered).to have_select(:taxonomy_content_id, options: ["", "title 1", "title 2"])
    end
  end

  context 'filter term' do
    it 'has an input to enter the query' do
      render

      expect(rendered).to have_selector('form input[name=query]')
    end
  end

  it "renders a button with the value of 'Filter' for executing the form action" do
    render

    expect(rendered).to have_selector("form input[type=submit][value=Filter]")
  end
end
