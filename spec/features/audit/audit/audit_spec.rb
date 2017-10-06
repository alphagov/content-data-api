RSpec.feature "Auditing a content item", type: :feature do
  let!(:content_item) do
    create(
      :content_item,
      title: "Flooding",
      description: "All about flooding.",
      base_path: "/flooding",
      publishing_app: "whitehall",
    )
  end

  let!(:user) { create(:user) }

  def answer_question(question, answer)
    find('p', text: question)
      .first(:xpath, '..//..')
      .choose(answer)
  end

  def expect_answer(question, answer)
    label_element = find('p', text: question)
                      .first(:xpath, "..//..//input[@type='radio'][@checked='checked']//..")

    expect(label_element).to have_content(answer)
  end

  scenario "auditing a content item" do
    visit content_item_audit_path(content_item)

    expect(page).to_not have_selector(".nav")

    expect(page).to have_link("Flooding", href: "https://gov.uk/flooding")
    expect(page).to have_content("All about flooding.")

    expect(page).to have_content("Do these things need to change?")

    answer_question "Title", "No"
    answer_question "Summary", "Yes"
    answer_question "Page detail", "No"
    fill_in "Notes", with: "something"

    click_on "Save and continue"
    expect(page).to have_content("Please answer all the questions.")

    answer_question "Attachments", "Yes"
    answer_question "Content type", "No"
    answer_question "Is the content out of date?", "Yes"

    answer_question "Should the content be removed?", "Yes"
    expect(page).to have_content("Where should users be redirected to? (optional)")
    fill_in "Where should users be redirected to? (optional)", with: "http://www.example.com"

    answer_question "Is this content very similar to other pages?", "Yes"
    fill_in "URLs of similar pages", with: "something"

    click_on "Save and continue"
    expect(page).to have_content("Audit saved — no items remaining.")

    expect_answer "Title", "No"
    expect_answer "Summary", "Yes"
    expect_answer "Page detail", "No"
    expect_answer "Attachments", "Yes"
    expect_answer "Content type", "No"
    expect_answer "Is the content out of date?", "Yes"
    expect_answer "Should the content be removed?", "Yes"
    expect(find_field("Where should users be redirected to? (optional)").value).to eq("http://www.example.com")
    expect_answer "Is this content very similar to other pages?", "Yes"
    expect(find_field("URLs of similar pages").value).to eq("something")
    expect(find_field("Notes").value).to eq("something")

    answer_question "Attachments", "Yes"
    answer_question "Content type", "No"
    answer_question "Is the content out of date?", "Yes"

    click_on "Save and continue"
    expect(page).to have_content("Audit saved — no items remaining.")

    expect_answer "Title", "No"
    expect_answer "Summary", "Yes"
    expect_answer "Page detail", "No"
    expect_answer "Attachments", "Yes"
    expect_answer "Content type", "No"
    expect_answer "Is the content out of date?", "Yes"
  end

  scenario "clicking on yes and no buttons for redundant/similar content questions", js: true do
    visit content_item_audit_path(content_item)

    expect(page).to have_no_content("Where should users be redirected to? (optional)")
    expect(page).to have_no_content("URLs of similar pages")

    answer_question "Should the content be removed?", "Yes"
    expect(page).to have_content("Where should users be redirected to? (optional)")

    answer_question "Should the content be removed?", "No"
    expect(page).to have_no_content("Where should users be redirected to? (optional)")

    answer_question "Is this content very similar to other pages?", "Yes"
    expect(page).to have_content("URLs of similar pages")

    answer_question "Is this content very similar to other pages?", "No"
    expect(page).to have_no_content("URLs of similar pages")
  end

  scenario "filling in and saving questions for redundant content", js: true do
    visit content_item_audit_path(content_item)

    answer_question "Title", "No"
    answer_question "Summary", "Yes"
    answer_question "Page detail", "No"
    fill_in "Notes", with: "something"
    answer_question "Attachments", "Yes"
    answer_question "Content type", "No"
    answer_question "Is the content out of date?", "Yes"
    answer_question "Should the content be removed?", "Yes"
    fill_in "Where should users be redirected to? (optional)", with: "http://www.example.com"
    answer_question "Is this content very similar to other pages?", "Yes"
    fill_in "URLs of similar pages", with: "http://www.example.com"

    click_on "Save"

    expect(page).to have_content("Where should users be redirected to? (optional)")
    expect(find_field("Where should users be redirected to? (optional)").value).to eq("http://www.example.com")
    expect(page).to have_content("URLs of similar pages")
    expect(find_field("URLs of similar pages").value).to eq("http://www.example.com")

    answer_question "Should the content be removed?", "No"
    answer_question "Is this content very similar to other pages?", "No"
    click_on "Save"

    expect(page).to have_no_content('Where should users be redirected to? (optional)')
    expect(page).to have_no_content("URLs of similar pages")

    answer_question "Should the content be removed?", "Yes"
    answer_question "Is this content very similar to other pages?", "Yes"
    expect(find_field("Where should users be redirected to? (optional)").value).to eq("")
    expect(find_field("URLs of similar pages").value).to eq("")
  end
end
