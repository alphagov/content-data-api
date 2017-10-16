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

  let!(:my_organisation) do
    create(
      :organisation,
      title: "YA Authors",
    )
  end

  let!(:me) do
    create(
      :user,
      name: "Garth Nix",
      organisation: my_organisation,
    )
  end

  scenario "auditing a content item" do
    audit_content_item = ContentAuditTool.new.audit_content_item
    audit_content_item.load(content_id: content_item.content_id)

    expect(page).to_not have_selector(".nav")

    expect(audit_content_item.content_item_title)
      .to have_link('Flooding', href: 'https://gov.uk/flooding')

    expect(audit_content_item)
      .to have_content_item_description(text: 'All about flooding.')

    expect(audit_content_item)
      .to have_questions_title(text: 'Do these things need to change?')

    audit_content_item.audit_form do |form|
      form.title.choose 'No'
      form.summary.choose 'Yes'
      form.page_detail.choose 'No'
      form.notes.set 'something'
      form.save_and_continue.click
    end

    expect(audit_content_item)
      .to have_error_message(text: 'Please answer all the questions.')

    audit_content_item.audit_form do |form|
      form.attachments.choose 'Yes'
      form.content_type.choose 'No'
      form.content_out_of_date.choose 'Yes'
      form.content_should_be_removed.choose 'Yes'
      expect(form).to have_redirect_urls
      form.redirect_urls.set 'https://example.com/redirect'
      form.content_similar.choose 'Yes'
      expect(form).to have_similar_urls
      form.similar_urls.set 'https://example.com/similar'
      form.save_and_continue.click
    end

    expect(audit_content_item)
      .to have_success_message(text: 'Audit saved — no items remaining.')

    audit_content_item.audit_form do |form|
      expect(form.title).to have_checked_field('No')
      expect(form.summary).to have_checked_field('Yes')
      expect(form.page_detail).to have_checked_field('No')
      expect(form.attachments).to have_checked_field('Yes')
      expect(form.content_type).to have_checked_field('No')
      expect(form.content_out_of_date).to have_checked_field('Yes')
      expect(form.content_should_be_removed).to have_checked_field('Yes')
      expect(form).to have_redirect_urls(text: 'https://example.com/redirect')
      expect(form.content_similar).to have_checked_field('Yes')
      expect(form).to have_similar_urls(text: 'https://example.com/similar')
      expect(form).to have_notes(text: 'something')
    end
  end

  scenario "clicking on yes and no buttons for redundant/similar content questions", js: true do
    audit_content_item = ContentAuditTool.new.audit_content_item
    audit_content_item.load(content_id: content_item.content_id)

    audit_content_item.audit_form do |form|
      expect(form).to have_no_redirect_urls
      expect(form).to have_no_similar_urls

      form.content_should_be_removed.choose 'Yes'
      expect(form).to have_redirect_urls

      form.content_should_be_removed.choose 'No'
      expect(form).to have_no_redirect_urls

      form.content_similar.choose 'Yes'
      expect(form).to have_similar_urls

      form.content_similar.choose 'No'
      expect(form).to have_no_similar_urls
    end
  end

  scenario "filling in and saving questions for redundant content", js: true do
    audit_content_item = ContentAuditTool.new.audit_content_item
    audit_content_item.load(content_id: content_item.content_id)

    audit_content_item.audit_form do |form|
      form.title.choose 'No'
      form.summary.choose 'Yes'
      form.page_detail.choose 'No'
      form.notes.set 'something'
      form.attachments.choose 'Yes'
      form.content_type.choose 'No'
      form.content_out_of_date.choose 'Yes'
      form.content_should_be_removed.choose 'Yes'
      form.redirect_urls.set 'https://example.com/redirect'
      form.content_similar.choose 'Yes'
      form.similar_urls.set 'https://example.com/similar'

      form.save_and_continue.click

      form.wait_for_redirect_urls
      form.wait_for_similar_urls

      expect(form).to have_redirect_urls(text: 'https://example.com/redirect')
      expect(form).to have_similar_urls(text: 'https://example.com/similar')

      form.content_should_be_removed.choose 'No'
      form.content_similar.choose 'No'

      form.save_and_continue.click

      form.wait_for_redirect_urls
      form.wait_for_similar_urls

      expect(form).to have_no_redirect_urls
      expect(form).to have_no_similar_urls

      form.content_should_be_removed.choose 'Yes'
      form.content_similar.choose 'Yes'

      expect(form).to have_redirect_urls(text: '')
      expect(form).to have_similar_urls(text: '')
    end
  end

  context "a content item is assigned to me" do
    let(:sabriel) { create(:content_item, allocated_to: me) }

    scenario "my name and organisation are shown on the content item" do
      audit_content_item = ContentAuditTool.new.audit_content_item
      audit_content_item.load(content_id: sabriel.content_id)

      expect(audit_content_item.metadata)
        .to have_assigned_to(text: 'Garth Nix YA Authors')
    end
  end
end
