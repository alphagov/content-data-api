require "rails_helper"

RSpec.describe "content_items/filter.html.erb", type: :view do
  describe "Form for filtering content items" do
    it "will render an empty select box if supplied with no organisation" do
      assign(:organisations, [])
      render

      expect(rendered).to have_selector("form select[name=organisation_slug]")
      expect(rendered).to have_selector('form select option', count: 0)
    end

    it "will render a select box with organisations if supplied a list of organisations" do
      organisations = [build(:organisation), build(:organisation)]
      assign(:organisations, organisations)
      render

      expect(rendered).to have_selector('form select option', count: 2)
    end

    it "renders a button with the value of 'Filter' for executing the form action" do
      assign(:organisations, [])
      render

      expect(rendered).to have_selector("form input[type=submit][value=Filter]")
    end
  end
end
