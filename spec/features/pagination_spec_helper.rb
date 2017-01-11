require 'rails_helper'

shared_examples "a paginated list" do |page_url|
  before do
    Kaminari.configure do |config|
      @default_per_page = config.default_per_page
      config.default_per_page = 1
    end
  end

  after do
    Kaminari.configure do |config|
      config.default_per_page = @default_per_page
    end
  end

  describe "next and previous flow" do
    it "on the first page, there is no previous link" do
      visit page_url

      expect(page).not_to have_selector('.govuk-previous-and-next-navigation [rel=prev]')
      expect(page).to have_selector('.govuk-previous-and-next-navigation [rel=next]', text: '2 of 3')
    end

    it "navigates to the next page" do
      visit page_url

      page.find('.govuk-previous-and-next-navigation a[rel=next]').click
      expect(page).to have_selector('.govuk-previous-and-next-navigation [rel=prev]', text: '1 of 3')
      expect(page).to have_selector('.govuk-previous-and-next-navigation [rel=next]', text: '3 of 3')
    end

    it "navigates to the previous page" do
      visit page_url
      page.find('.govuk-previous-and-next-navigation a[rel=next]').click
      page.find('.govuk-previous-and-next-navigation a[rel=prev]').click

      expect(page).not_to have_selector('.govuk-previous-and-next-navigation [rel=prev]')
      expect(page).to have_selector('.govuk-previous-and-next-navigation [rel=next]', text: '2 of 3')
    end
  end
end
