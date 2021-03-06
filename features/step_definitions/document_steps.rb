THE_DOCUMENT = Transform(/the (document|publication|policy|news article|consultation|consultation response|speech|international priority) "([^"]*)"/) do |document_type, title|
  document = document_class(document_type).latest_edition.find_by_title!(title)
end

Given /^a draft (document|publication|policy|news article|consultation|speech) "([^"]*)" exists$/ do |document_type, title|
  document_type = 'policy' if document_type == 'document'
  create("draft_#{document_class(document_type).name.underscore}".to_sym, title: title)
end

Given /^a published (publication|policy|news article|consultation|speech) "([^"]*)" exists$/ do |document_type, title|
  create("published_#{document_class(document_type).name.underscore}".to_sym, title: title)
end

Given /^a published document "([^"]*)" exists$/ do |title|
  create(:published_policy, title: title)
end

Given /^a (draft|published) document "([^"]*)" exists which links to the "([^"]*)" document$/ do |state, source_title, target_title|
  target_document = Document.find_by_title!(target_title)
  target_url = admin_document_url(target_document)
  body = "[#{target_title}](#{target_url})"
  create("#{state}_policy", title: source_title, body: body)
end

Given /^a draft (publication|policy|news article|consultation) "([^"]*)" exists in the "([^"]*)" policy area$/ do |document_type, title, policy_area_name|
  policy_area = PolicyArea.find_by_name!(policy_area_name)
  create("draft_#{document_class(document_type).name.underscore}".to_sym, title: title, policy_areas: [policy_area])
end

Given /^a published (publication|policy|news article|consultation) "([^"]*)" exists in the "([^"]*)" policy area$/ do |document_type, title, policy_area_name|
  policy_area = PolicyArea.find_by_name!(policy_area_name)
  create("published_#{document_class(document_type).name.underscore}".to_sym, title: title, policy_areas: [policy_area])
end

Given /^a draft (publication|policy|news article|consultation) "([^"]*)" was produced by the "([^"]*)" organisation$/ do |document_type, title, organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  create("draft_#{document_class(document_type).name.underscore}".to_sym, title: title, organisations: [organisation])
end

Given /^a published (publication|policy|news article|consultation) "([^"]*)" was produced by the "([^"]*)" organisation$/ do |document_type, title, organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  create("published_#{document_class(document_type).name.underscore}".to_sym, title: title, organisations: [organisation])
end

Given /^a submitted (publication|policy|news article|consultation|speech|international priority) "([^"]*)" exists$/ do |document_type, title|
  create("submitted_#{document_class(document_type).name.underscore}".to_sym, title: title)
end

Given /^another user edits the (publication|policy|news article|consultation|speech) "([^"]*)" changing the title to "([^"]*)"$/ do |document_type, original_title, new_title|
  document = document_class(document_type).find_by_title!(original_title)
  document.update_attributes!(title: new_title)
end

Given /^a published (publication|policy|news article|consultation|speech) "([^"]*)" that's the responsibility of:$/ do |document_type, title, table|
  document = create(:"published_#{document_type}", title: title)
  table.hashes.each do |row|
    person = find_or_create_person(row["Person"])
    ministerial_role = MinisterialRole.find_or_create_by_name(row["Ministerial Role"])
    create(:role_appointment, role: ministerial_role, person: person)
    document.ministerial_roles << ministerial_role
  end
end

Given /^a featured (publication|news article) "([^"]*)" exists$/ do |document_type, title|
  create("featured_#{document_class(document_type).name.underscore}", title: title)
end

When /^I view the (publication|policy|news article|consultation|speech) "([^"]*)"$/ do |document_type, title|
  click_link title
end

When /^I visit the list of draft documents$/ do
  visit draft_admin_documents_path
end

When /^I visit the list of documents awaiting review$/ do
  visit submitted_admin_documents_path
end

When /^I select the "([^"]*)" filter$/ do |filter|
  click_link filter
end

When /^I visit the (publication|policy|news article|consultation) "([^"]*)"$/ do |document_type, title|
  document = document_class(document_type).find_by_title!(title)
  visit public_document_path(document)
end

When /^I submit (#{THE_DOCUMENT})$/ do |document|
  visit_document_preview document.title
  click_button "Submit to 2nd pair of eyes"
end

When /^I publish (#{THE_DOCUMENT})$/ do |document|
  visit_document_preview document.title
  publish
end

When /^I force publish (#{THE_DOCUMENT})$/ do |document|
  visit_document_preview document.title, :draft
  publish(force: true)
end

When /^I save my changes to the (publication|policy|news article|consultation|speech)$/ do |document_type|
  click_button "Save"
end

When /^I edit the (publication|policy|news article|consultation) changing the title to "([^"]*)"$/ do |document_type, new_title|
  fill_in "Title", with: new_title
  click_button "Save"
end

When /^I create a new edition of the published document "([^"]*)"$/ do |title|
  visit published_admin_documents_path
  click_link title
  click_button 'Create new edition'
end

When /^I publish a new edition of the published document "([^"]*)"$/ do |title|
  visit published_admin_documents_path
  click_link title
  click_button 'Create new edition'
  click_button 'Save'
  publish(force: true)
end

Then /^I should see (#{THE_DOCUMENT})$/ do |document|
  assert has_css?(record_css_selector(document))
end

Then /^I should not see (#{THE_DOCUMENT})$/ do |document|
  refute has_css?(record_css_selector(document))
end

Then /^I should see (#{THE_DOCUMENT}) in the list of draft documents$/ do |document|
  visit admin_documents_path
  assert has_css?(record_css_selector(document))
end

Then /^I should see (#{THE_DOCUMENT}) in the list of submitted documents$/ do |document|
  visit submitted_admin_documents_path
  assert has_css?(record_css_selector(document))
end

Then /^I should see (#{THE_DOCUMENT}) in the list of published documents$/ do |document|
  visit published_admin_documents_path
  assert has_css?(record_css_selector(document))
end

Then /^I should not see the policy "([^"]*)" in the list of draft documents$/ do |title|
  visit admin_documents_path
  assert has_no_css?(".policy a", text: title)
end

Then /^(#{THE_DOCUMENT}) should be visible to the public$/ do |document|
  visit homepage
  case document
  when Publication
    click_link "Publications"
  when NewsArticle, Speech
    click_link "News & speeches"
  when Consultation
    click_link "Consultations"
  when Policy
    visit policies_path
  when InternationalPriority
    visit international_priorities_path
  else
    raise "Don't know what to click on for #{document.class.name}s"
  end
  assert page.has_css?(record_css_selector(document), text: document.title)
end

Then /^I should see in the preview that "([^"]*)" should be in the "([^"]*)" and "([^"]*)" policy areas$/ do |title, first_policy_area, second_policy_area|
  visit_document_preview title
  assert has_css?(".policy_area", text: first_policy_area)
  assert has_css?(".policy_area", text: second_policy_area)
end

Then /^I should see in the preview that "([^"]*)" was produced by the "([^"]*)" and "([^"]*)" organisations$/ do |title, first_org, second_org|
  visit_document_preview title
  assert has_css?(".organisation", text: first_org)
  assert has_css?(".organisation", text: second_org)
end

Then /^I should see in the preview that "([^"]*)" is associated with "([^"]*)" and "([^"]*)"$/ do |title, minister_1, minister_2|
  visit_document_preview title
  assert has_css?(".ministerial_role", text: minister_1)
  assert has_css?(".ministerial_role", text: minister_2)
end

Then /^I should see in the preview that "([^"]*)" does not apply to the nations:$/ do |title, nation_names|
  visit_document_preview title
  nation_names.raw.flatten.each do |nation_name|
    assert has_css?(".nation_inapplicability", nation_name)
  end
end

Then /^I should see in the preview that "([^"]*)" should related to "([^"]*)" and "([^"]*)" policies$/ do |title, related_policy_1, related_policy_2|
  visit_document_preview title
  assert has_css?("#related-documents .policy", text: related_policy_1)
  assert has_css?("#related-documents .policy", text: related_policy_2)
end

Then /^I should see in the preview that "([^"]*)" does (not )?have a public link to "([^"]*)"/ do |source_title, should_not_have_link, target_title|
  visit_document_preview source_title
  target_document = Document.find_by_title!(target_title)
  target_path = policy_path(target_document.document_identity)

  has_link = has_link?(target_title, href: target_path)
  if should_not_have_link
    refute has_link
  else
    assert has_link
  end
end

Then /^I should see in the preview that "([^"]*)" does have an admin link to the (draft|published) edition of "([^"]*)"$/ do |source_title, state, target_title|
  visit_document_preview source_title
  target_document = Document.send(state).find_by_title!(target_title)
  assert has_link?(state, href: admin_document_path(target_document))
end

Then /^I should see the conflict between the (publication|policy|news article|consultation|speech) titles "([^"]*)" and "([^"]*)"$/ do |document_type, new_title, latest_title|
  assert page.has_css?(".conflicting.new #document_title", value: new_title)
  assert page.has_css?(".conflicting.latest .document .title", value: latest_title)
end

Then /^my attempt to publish "([^"]*)" should fail$/ do |title|
  document = Document.latest_edition.find_by_title!(title)
  assert !document.published?
end

Then /^my attempt to publish "([^"]*)" should succeed$/ do |title|
  document = Document.latest_edition.find_by_title!(title)
  assert document.published?
end

Then /^the published document "([^"]*)" should still link to the "([^"]*)" document$/ do |source_title, target_title|
  source_document = Document.find_by_title!(source_title)
  target_document = Document.find_by_title!(target_title)
  visit policy_path(source_document.document_identity)
  target_path = policy_path(target_document.document_identity)
  assert has_link?(target_title, href: target_path)
end
