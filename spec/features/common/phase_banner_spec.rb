RSpec.feature "Phase banner", type: :feature do
  before do
    create(:user)
  end

  scenario 'the user can see a ALPHA phase banner' do
    visit '/'

    within('.phase-banner') do
      expect(page).to have_text('ALPHA')
    end
  end
end
