RSpec.feature "Auditing a content item", type: :feature do
  let!(:content_item) do
    FactoryGirl.create(
      :content_item,
      title: "Flooding",
      description: "All about flooding.",
      base_path: "/flooding",
      publishing_app: "whitehall",
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

    expect(page).to have_link("Open in Whitehall Publisher")

    expect(page).to have_content("Do these things need to change?")

    within("#question-1") { choose "No" }
    within("#question-2") { choose "Yes" }
    within("#question-3") { choose "No" }
    within("#question-10") { fill_in "Notes", with: "something" }

    click_on "Save"
    expect(page).to have_content("Warning: Mandatory field missing")

    within("#question-4") { choose "Yes" }
    within("#question-5") { choose "No" }
    within("#question-6") { choose "Yes" }
    within("#question-7") { choose "Yes" }
    within("#question-8") { choose "Yes" }
    within("#question-9") { fill_in "URLs of similar pages", with: "something" }

    click_on "Save"
    expect(page).to have_content("Success: Saved successfully.")

    within("#question-1") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-2") { expect(chosen_radio_button.value).to eq("yes") }
    within("#question-3") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-4") { expect(chosen_radio_button.value).to eq("yes") }
    within("#question-5") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-6") { expect(chosen_radio_button.value).to eq("yes") }
    within("#question-10") { expect(find_field("Notes").value).to eq("something") }

    within("#question-4") { choose "Yes" }
    within("#question-5") { choose "No" }
    within("#question-6") { choose "Yes" }

    click_on "Save"
    expect(page).to have_content("Success: Saved successfully.")

    within("#question-1") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-2") { expect(chosen_radio_button.value).to eq("yes") }
    within("#question-3") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-4") { expect(chosen_radio_button.value).to eq("yes") }
    within("#question-5") { expect(chosen_radio_button.value).to eq("no") }
    within("#question-6") { expect(chosen_radio_button.value).to eq("yes") }
  end
end
