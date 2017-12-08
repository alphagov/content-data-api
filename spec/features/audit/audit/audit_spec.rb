RSpec.feature 'Auditing a content item', type: :feature do
  scenario 'information about the published content is available' do
    given_i_am_auditing_a_content_item
    then_the_title_is_shown_linking_to_the_published_content
    and_the_description_is_shown
  end

  scenario 'information about the assignee is available' do
    given_i_am_auditing_a_content_item
    then_the_name_of_the_assignee_is_shown
  end

  scenario 'all questions must be answered' do
    given_i_am_auditing_a_content_item
    then_i_am_prompted_to_consider_if_it_needs_to_change
    when_i_answer_some_of_the_questions
    then_an_error_message_is_shown
  end

  scenario 'answers are remembered' do
    given_i_am_auditing_a_content_item
    when_i_answer_all_of_the_questions
    then_a_success_message_is_shown
    and_my_answers_to_the_questions_are_remembered
    and_i_can_still_see_the_content_preview
  end

  scenario 'clicking on yes and no buttons for redundant/similar content questions', js: true do
    given_i_am_auditing_a_content_item
    then_i_am_prompted_to_specify_redirect_urls_if_the_content_should_be_removed
  end

  scenario 'filling in and saving questions for redundant content', js: true do
    given_i_am_auditing_a_content_item
    when_i_specify_urls
    then_the_urls_i_specified_are_shown
    when_i_specify_that_the_content_is_relevant
    then_the_urls_i_previously_specified_are_discarded
  end

private

  def given_i_am_auditing_a_content_item
    organisation = create(:organisation, title: 'YA Authors')
    user = create(:user, name: 'Garth Nix', organisation: organisation)

    content_item = create(
      :content_item,
      allocated_to: user,
      title: 'Flooding',
      description: 'All about flooding.',
      base_path: '/flooding',
      publishing_app: 'whitehall',
    )

    @audit_content_item = ContentAuditTool.new.audit_content_item
    @audit_content_item.load(content_id: content_item.content_id)
  end

  def then_i_am_prompted_to_consider_if_it_needs_to_change
    expect(@audit_content_item)
      .to have_questions_title(text: 'Do these things need to change?')
  end

  def then_the_name_of_the_assignee_is_shown
    expect(@audit_content_item)
      .to have_assigned_to(text: 'Garth Nix')
  end

  def when_i_answer_some_of_the_questions
    @audit_content_item.audit_form do |form|
      form.title.choose 'No'
      form.summary.choose 'Yes'
      form.page_detail.choose 'No'
      form.notes.set 'something'
      form.save_and_continue.click
    end
  end

  def when_i_answer_all_of_the_questions
    @audit_content_item.audit_form do |form|
      form.title.choose 'No'
      form.summary.choose 'Yes'
      form.page_detail.choose 'No'
      form.attachments.choose 'Yes'
      form.content_type.choose 'No'
      form.content_out_of_date.choose 'Yes'
      form.content_should_be_removed.choose 'Yes'
      expect(form).to have_redirect_urls
      form.redirect_urls.set 'https://example.com/redirect'
      form.content_similar.choose 'Yes'
      expect(form).to have_similar_urls
      form.similar_urls.set 'https://example.com/similar'
      form.notes.set 'something'
      form.save_and_continue.click
    end
  end

  def when_i_specify_that_the_content_is_relevant
    @audit_content_item.audit_form do |form|
      form.content_should_be_removed.choose 'No'
      form.content_similar.choose 'No'

      form.save_and_continue.click
    end
  end

  def when_i_specify_urls
    @audit_content_item.audit_form do |form|
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
    end
  end

  def then_a_success_message_is_shown
    expect(@audit_content_item)
      .to have_success_message(text: 'Audit saved — no items remaining.')
  end

  def then_an_error_message_is_shown
    expect(@audit_content_item)
      .to have_error_message(text: 'Please answer all the questions.')
  end

  def then_the_title_is_shown_linking_to_the_published_content
    expect(@audit_content_item.content_item_title)
      .to have_link('Flooding', href: 'https://gov.uk/flooding')
  end

  def and_the_description_is_shown
    expect(@audit_content_item)
      .to have_content_item_description(text: 'All about flooding.')
  end

  def and_my_answers_to_the_questions_are_remembered
    @audit_content_item.audit_form do |form|
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

  def and_i_can_still_see_the_content_preview
    expect(@audit_content_item).to have_content_preview
  end

  def then_i_am_prompted_to_specify_redirect_urls_if_the_content_should_be_removed
    @audit_content_item.audit_form do |form|
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

  def then_the_urls_i_specified_are_shown
    @audit_content_item.audit_form do |form|
      form.wait_for_redirect_urls
      form.wait_for_similar_urls

      expect(form).to have_redirect_urls(text: 'https://example.com/redirect')
      expect(form).to have_similar_urls(text: 'https://example.com/similar')
    end
  end

  def then_the_urls_i_previously_specified_are_discarded
    @audit_content_item.audit_form do |form|
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
end
