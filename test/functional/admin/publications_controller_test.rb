require 'test_helper'

class Admin::PublicationsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :publication
  should_allow_creating_of :publication
  should_allow_editing_of :publication

  should_allow_organisations_for :publication
  should_allow_ministerial_roles_for :publication
  should_allow_attachments_for :publication
  should_allow_association_between_countries_and :publication
  should_be_rejectable :publication
  should_be_publishable :publication
  should_be_force_publishable :publication
  should_be_able_to_delete_a_document :publication
  should_link_to_public_version_when_published :publication
  should_not_link_to_public_version_when_not_published :publication
  should_prevent_modification_of_unmodifiable :publication

  test "new displays publication fields" do
    get :new

    assert_select "form#document_new" do
      assert_select "select[name*='document[publication_date']", count: 3
      assert_select "input[name='document[unique_reference]'][type='text']"
      assert_select "input[name='document[isbn]'][type='text']"
      assert_select "input[name='document[research]'][type='checkbox']"
      assert_select "input[name='document[order_url]'][type='text']"
    end
  end

  test "create should create a new publication" do
    first_policy = create(:published_policy)
    second_policy = create(:published_policy)
    attributes = attributes_for(:publication,
      publication_date: Date.parse("1805-10-21"),
      unique_reference: "unique-reference",
      isbn: "0140621431",
      research: true,
      order_url: "http://example.com/order-path"
    )

    post :create, document: attributes.merge(
      related_document_identity_ids: [first_policy.document_identity.id, second_policy.document_identity.id]
    )

    created_publication = Publication.last
    assert_equal [first_policy, second_policy], created_publication.related_policies
    assert_equal Date.parse("1805-10-21"), created_publication.publication_date
    assert_equal "unique-reference", created_publication.unique_reference
    assert_equal "0140621431", created_publication.isbn
    assert created_publication.research?
    assert_equal "http://example.com/order-path", created_publication.order_url
  end

  test "edit displays publication fields" do
    publication = create(:publication)

    get :edit, id: publication

    assert_select "form#document_edit" do
      assert_select "select[name*='document[publication_date']", count: 3
      assert_select "input[name='document[unique_reference]'][type='text']"
      assert_select "input[name='document[isbn]'][type='text']"
      assert_select "input[name='document[research]'][type='checkbox']"
      assert_select "input[name='document[order_url]'][type='text']"
    end
  end

  test "update should save modified publication attributes" do
    publication = create(:publication)

    put :update, id: publication, document: publication.attributes.merge(
      publication_date: Date.parse("1815-06-18"),
      unique_reference: "new-reference",
      isbn: "0099532816",
      research: true,
      order_url: "https://example.com/new-order-path"
    )

    saved_publication = publication.reload
    assert_equal Date.parse("1815-06-18"), saved_publication.publication_date
    assert_equal "new-reference", saved_publication.unique_reference
    assert_equal "0099532816", saved_publication.isbn
    assert saved_publication.research?
    assert_equal "https://example.com/new-order-path", saved_publication.order_url
  end

  test "update should remove all related documents if none in params" do
    policy = create(:policy)
    publication = create(:publication, related_policies: [policy])

    put :update, id: publication, document: {}

    publication.reload
    assert_equal [], publication.related_policies
  end

  test "should display publication attributes" do
    publication = create(:publication,
      publication_date: Date.parse("1916-05-31"),
      unique_reference: "unique-reference",
      isbn: "0099532816",
      research: true,
      order_url: "http://example.com/order-path"
    )

    get :show, id: publication

    assert_select ".document_view" do
      assert_select ".publication_date", text: "May 31st, 1916"
      assert_select ".unique_reference", text: "unique-reference"
      assert_select ".isbn", text: "0099532816"
      assert_select ".research", text: "Yes"
      assert_select "a.order_url[href='http://example.com/order-path']"
    end
  end

  test "should not display an order link if no order url exists" do
    publication = create(:publication, order_url: nil)

    get :show, id: publication

    assert_select ".document_view" do
      refute_select "a.order_url"
    end
  end
end
