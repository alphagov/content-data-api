require "rails_helper"

RSpec.describe "content_items/filter.html.erb", type: :view do
  describe "Form for filtering content items" do
    before do
      assign(:organisations, [])
      assign(:taxonomies, [])
    end

    context "filtering organisations" do
      it "will render select boxes with options for 2 organisations and 1 empty if supplied with list of 2 organisations" do
        organisations = [build(:organisation), build(:organisation)]
        assign(:organisations, organisations)
        render

        expect(rendered).to have_selector('form select#organisation_id option', count: 3)
      end
    end

    context "filtering by taxonomies" do
      it "will render select boxes with with options for 2 taxonomies and 1 empty if supplied with list of 2 taxonomies" do
        taxonomies = [build(:taxonomy), build(:taxonomy)]
        assign(:taxonomies, taxonomies)
        render

        expect(rendered).to have_selector('form select#taxonomy_content_id option', count: 3)
      end
    end

    it "renders a button with the value of 'Filter' for executing the form action" do
      render

      expect(rendered).to have_selector("form input[type=submit][value=Filter]")
    end
  end
end
