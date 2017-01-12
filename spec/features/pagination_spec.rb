require 'rails_helper'

RSpec.feature "Content Item's Pagination", type: :feature do
  let(:organisation) { create(:organisation_with_content_items, content_items_count: 3) }

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

  scenario 'When user navigates to the first page, there is no previous link' do
    visit "organisations/#{organisation.slug}/content_items"

    expect(page).not_to have_selector('.govuk-previous-and-next-navigation [rel=prev]')
    expect(page).to have_selector('.govuk-previous-and-next-navigation [rel=next]', text: '2 of 3')
  end

  scenario 'When user navigates to the next page, it navigates to page 2' do
    visit "organisations/#{organisation.slug}/content_items"
    page.find('.govuk-previous-and-next-navigation a[rel=next]').click

    expect(page).to have_selector('.govuk-previous-and-next-navigation [rel=prev]', text: '1 of 3')
    expect(page).to have_selector('.govuk-previous-and-next-navigation [rel=next]', text: '3 of 3')
  end

  scenario 'When user navigates to the previous page from page 3, it navigates to page 2' do
    visit "organisations/#{organisation.slug}/content_items?page=3"
    page.find('.govuk-previous-and-next-navigation a[rel=prev]').click

    expect(page).to have_selector('.govuk-previous-and-next-navigation [rel=prev]', text: '1 of 3')
    expect(page).to have_selector('.govuk-previous-and-next-navigation [rel=next]', text: '3 of 3')
  end
end
