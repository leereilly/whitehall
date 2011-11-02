require "test_helper"

class Document::PublishingTest < ActiveSupport::TestCase
  test "is publishable by an editor when submitted" do
    document = create(:submitted_policy)
    assert document.publishable_by?(create(:departmental_editor))
  end

  test "is never publishable by a writer" do
    document = create(:submitted_policy)
    refute document.publishable_by?(create(:policy_writer))
    assert_equal "Only departmental editors can publish", document.reason_to_prevent_publication_by(create(:policy_writer))
  end

  test "is never publishable when already published" do
    document = create(:published_policy)
    refute document.publishable_by?(create(:departmental_editor))
    assert_equal "This edition has already been published", document.reason_to_prevent_publication_by(create(:departmental_editor))
  end

  test "is not normally publishable when not submitted" do
    document = create(:draft_policy)
    refute document.publishable_by?(create(:departmental_editor))
    assert_equal "Not ready for publication", document.reason_to_prevent_publication_by(create(:departmental_editor))
  end

  test "is publishable when not submitted if force flag provided" do
    document = create(:draft_policy)
    assert document.publishable_by?(create(:departmental_editor), force: true)
  end

  test "is not normally publishable by the original author" do
    editor = create(:departmental_editor)
    document = create(:submitted_policy, author: editor)
    refute document.publishable_by?(editor)
    assert_equal "You are not the second set of eyes", document.reason_to_prevent_publication_by(editor)
  end

  test "is publishable by the original author if force flag provided" do
    editor = create(:departmental_editor)
    document = create(:submitted_policy, author: editor)
    assert document.publishable_by?(editor, force: true)
  end

  test "is never publishable when archived" do
    document = create(:archived_policy)
    refute document.publishable_by?(create(:departmental_editor))
    assert_equal "This edition has been archived", document.reason_to_prevent_publication_by(create(:departmental_editor))
  end

  test "publication marks document as published" do
    document = create(:submitted_policy)
    document.publish_as(create(:departmental_editor))
    assert document.reload.published?
  end

  test "publication archives previous published versions" do
    published_policy = create(:published_policy)
    document = create(:submitted_policy, document_identity: published_policy.document_identity)
    document.publish_as(create(:departmental_editor))
    assert published_policy.reload.archived?
  end

  test "publication fails if not publishable by user" do
    editor = create(:departmental_editor)
    document = create(:submitted_policy)
    document.stubs(:publishable_by?).with(editor, {}).returns(false)
    refute document.publish_as(editor)
    refute document.reload.published?
  end

  test "publication adds reason for failure to validation errors" do
    editor = create(:departmental_editor)
    document = create(:submitted_policy)
    document.stubs(:publishable_by?).returns(false)
    document.stubs(:reason_to_prevent_publication_by).with(editor, {}).returns('a spurious reason')
    document.publish_as(editor)
    assert_equal ['a spurious reason'], document.errors.full_messages
  end

  test "publication raises StaleObjectError if lock version is not current" do
    document = create(:submitted_policy, title: "old title")

    Document.find(document.id).update_attributes(title: "new title")

    assert_raises(ActiveRecord::StaleObjectError) do
      document.publish_as(create(:departmental_editor))
    end
    refute Document.find(document.id).published?
  end
end