RSpec.feature "Auditing a content item", type: :feature do
  let!(:content_item) do
    FactoryGirl.create(
      :content_item,
      title: "Flooding",
      description: "All about flooding.",
      base_path: "/flooding",
    )
  end

  let!(:user) { FactoryGirl.create(:user) }

  def chosen_radio_button
    first("input[@type='radio'][@checked='checked']")
  end

  scenario "auditing a content item" do
    visit content_item_audit_path(content_item)
    expect(page).to have_link("Flooding", href: "https://gov.uk/flooding")
    expect(page).to have_content("All about flooding.")
    expect(page).to have_content("Audited by no one")

    within("#question-1") { choose "Yes" }
    within("#question-2") { choose "No" }
    within("#question-3") { choose "Yes" }
    within("#question-8") { fill_in "Notes", with: "something" }

    click_on "Save"
    expect(page).to have_content("Warning: Mandatory field missing")

    within("#question-4") { choose "No" }
    within("#question-5") { choose "Yes" }
    within("#question-6") { choose "No" }

    click_on "Save"
    expect(page).to have_content("Success: Saved successfully.")
    expect(page).to have_content("Audited by Test User")

    within("#question-1") { expect(chosen_radio_button.value).to eq("yes") }
    within("#question-2") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-3") { expect(chosen_radio_button.value).to eq("yes") }
    within("#question-4") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-5") { expect(chosen_radio_button.value).to eq("yes") }
    within("#question-6") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-8") { expect(find_field("Notes").value).to eq("something") }

    within("#question-4") { choose "Yes" }
    within("#question-5") { choose "No" }
    within("#question-6") { choose "Yes" }

    click_on "Save"
    expect(page).to have_content("Success: Saved successfully.")

    within("#question-1") { expect(chosen_radio_button.value).to eq("yes") }
    within("#question-2") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-3") { expect(chosen_radio_button.value).to eq("yes") }
    within("#question-4") { expect(chosen_radio_button.value).to eq("yes") }
    within("#question-5") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-6") { expect(chosen_radio_button.value).to eq("yes") }
  end
end
