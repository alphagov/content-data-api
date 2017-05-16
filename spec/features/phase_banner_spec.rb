require 'rails_helper'

RSpec.feature "Phase banner", type: :feature do
  before do
    FactoryGirl.create(:user)
  end

  scenario "The user can see a phase banner" do
    visit "/"

    expect(page).to have_selector(".phase-banner", count: 1)
  end
end
