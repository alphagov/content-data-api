require "rails_helper"

RSpec.describe "content_items/filter.html.erb", type: :view do
  describe "Form for filtering content items" do
    it "will render an empty select box if supplied with no data" do
      assign(:organisations, [])
      assign(:taxonomies, [])
      render

      expect(rendered).to have_selector("form select[name=organisation_slug]")
      expect(rendered).to have_selector("form select[name=taxonomy_title]")
      expect(rendered).to have_selector('form select option', count: 2)
    end

    it "will render select boxes with organisations and taxonomies if supplied with lists of organisations and taxonomies" do
      organisations = [build(:organisation), build(:organisation)]
      taxonomies = [build(:taxonomy), build(:taxonomy)]
      assign(:organisations, organisations)
      assign(:taxonomies, taxonomies)
      render

      expect(rendered).to have_selector('form select option', count: 6)
    end

    it "renders a button with the value of 'Filter' for executing the form action" do
      assign(:organisations, [])
      assign(:taxonomies, [])
      render

      expect(rendered).to have_selector("form input[type=submit][value=Filter]")
    end
  end
end
