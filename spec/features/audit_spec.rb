RSpec.feature "Auditing a content item", type: :feature do
  let!(:content_item) { FactoryGirl.create(:content_item) }
  let!(:user) { FactoryGirl.create(:user) }

  def chosen_radio_button
    first("input[@type='radio'][@checked='checked']")
  end

  scenario "auditing a content item" do
    visit content_item_audit_path(content_item)

    within("#question-1") { choose "Yes" }
    within("#question-2") { choose "No" }
    within("#question-5") { choose "No" }
    within("#question-6") { choose "Yes" }

    click_on "Save"
    expect(page).to have_content("Audit saved successfully.")

    within("#question-1") { expect(chosen_radio_button.value).to eq("yes") }
    within("#question-2") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-3") { expect(chosen_radio_button).to be_nil }
    within("#question-4") { expect(chosen_radio_button).to be_nil }
    within("#question-5") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-6") { expect(chosen_radio_button.value).to eq("yes") }

    within("#question-4") { choose "No" }
    within("#question-5") { choose "Yes" }
    within("#question-6") { choose "No" }

    click_on "Save"
    expect(page).to have_content("Audit saved successfully.")

    within("#question-1") { expect(chosen_radio_button.value).to eq("yes") }
    within("#question-2") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-3") { expect(chosen_radio_button).to be_nil }
    within("#question-4") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-5") { expect(chosen_radio_button.value).to eq("yes") }
    within("#question-6") { expect(chosen_radio_button.value).to eq("no") }
  end
end
