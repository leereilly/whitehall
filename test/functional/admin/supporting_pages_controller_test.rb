require "test_helper"

class Admin::SupportingPagesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "new form has title and body inputs" do
    document = create(:draft_policy)

    get :new, document_id: document

    assert_select "form[action='#{admin_document_supporting_pages_path(document)}']" do
      assert_select "input[name='supporting_page[title]'][type='text']"
      assert_select "textarea[name='supporting_page[body]']"
      assert_select "input[type='submit']"
    end
  end

  test "new form has previewable body" do
    document = create(:draft_policy)

    get :new, document_id: document

    assert_select "textarea[name='supporting_page[body]'].previewable"
  end

  test "create adds supporting page" do
    document = create(:draft_policy)
    attributes = { title: "title", body: "body" }
    post :create, document_id: document, supporting_page: attributes

    assert supporting_page = document.supporting_pages.last
    assert_equal attributes[:title], supporting_page.title
    assert_equal attributes[:body], supporting_page.body
  end

  test "create should redirect to the document page" do
    policy = create(:draft_policy)
    attributes = { title: "title", body: "body" }
    post :create, document_id: policy, supporting_page: attributes

    assert_redirected_to admin_policy_path(policy)
    assert_equal flash[:notice], "The supporting page was added successfully"
  end

  test "create should render the form when attributes are invalid" do
    document = create(:draft_policy)
    invalid_attributes = { title: nil, body: "body" }
    post :create, document_id: document, supporting_page: invalid_attributes

    assert_template "new"
    assert_equal "There was a problem: Title can't be blank", flash[:alert]
  end

  test "shows the title and a link back to the parent" do
    document = create(:draft_policy)
    supporting_page = create(:supporting_page, document: document)

    get :show, id: supporting_page

    assert_select ".title", supporting_page.title
    assert_select "a[href='#{admin_policy_path(document)}']", text: "Back to '#{document.title}'"
  end

  test "shows the body using govspeak markup" do
    supporting_page = create(:supporting_page, body: "body-in-govspeak")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, id: supporting_page

    assert_select ".body", text: "body-in-html"
  end

  test "shows edit link if parent document is not published" do
    document = create(:draft_policy)
    supporting_page = create(:supporting_page, document: document)

    get :show, document_id: document, id: supporting_page

    assert_select "a[href='#{edit_admin_supporting_page_path(supporting_page)}']", text: 'Edit'
  end

  test "doesn't show edit link if parent document is published" do
    document = create(:published_policy)
    supporting_page = create(:supporting_page, document: document)

    get :show, document_id: document, id: supporting_page

    refute_select "a[href='#{edit_admin_supporting_page_path(supporting_page)}']"
  end

  test "edit form has title and body inputs" do
    document = create(:draft_policy)
    supporting_page = create(:supporting_page, document: document)

    get :edit, document_id: document, id: supporting_page

    assert_select "form[action='#{admin_supporting_page_path(supporting_page)}']" do
      assert_select "input[name='supporting_page[title]'][type='text'][value='#{supporting_page.title}']"
      assert_select "textarea[name='supporting_page[body]']", text: supporting_page.body
      assert_select "input[type='submit']"
    end
  end

  test "edit form has previewable body" do
    document = create(:draft_policy)
    supporting_page = create(:supporting_page, document: document)

    get :edit, document_id: document, id: supporting_page

    assert_select "textarea[name='supporting_page[body]'].previewable"
  end

  test "edit form include lock version to prevent conflicting changes overwriting each other" do
    document = create(:draft_policy)
    supporting_page = create(:supporting_page, document: document)

    get :edit, document_id: document, id: supporting_page

    assert_select "form[action='#{admin_supporting_page_path(supporting_page)}']" do
      assert_select "input[name='supporting_page[lock_version]'][type='hidden'][value='#{supporting_page.lock_version}']"
    end
  end

  test "update modifies supporting page" do
    supporting_page = create(:supporting_page)

    attributes = { title: "new-title", body: "new-body" }
    put :update, id: supporting_page, supporting_page: attributes

    supporting_page.reload
    assert_equal attributes[:title], supporting_page.title
    assert_equal attributes[:body], supporting_page.body
  end

  test "update should redirect to the supporting page" do
    supporting_page = create(:supporting_page)

    attributes = { title: "new-title", body: "new-body" }
    put :update, id: supporting_page, supporting_page: attributes

    assert_redirected_to admin_supporting_page_path(supporting_page)
    assert_equal flash[:notice], "The supporting page was updated successfully"
  end

  test "update should render the form when attributes are invalid" do
    supporting_page = create(:supporting_page)

    attributes = { title: nil, body: "new-body" }
    put :update, id: supporting_page, supporting_page: attributes

    assert_template "edit"
    assert_equal "There was a problem: Title can't be blank", flash[:alert]
  end

  test "updating a stale supporting page should render edit page with conflicting supporting page" do
    supporting_page = create(:supporting_page)
    lock_version = supporting_page.lock_version
    supporting_page.touch

    attributes = { title: "new-title", body: "new-body" }
    put :update, id: supporting_page, supporting_page: attributes.merge(lock_version: lock_version)

    assert_template 'edit'
    conflicting_supporting_page = supporting_page.reload
    assert_equal conflicting_supporting_page, assigns[:conflicting_supporting_page]
    assert_equal conflicting_supporting_page.lock_version, assigns[:supporting_page].lock_version
    assert_equal %{This page has been saved since you opened it. Your version appears at the top and the latest version appears at the bottom. Please incorporate any relevant changes into your version and then save it.}, flash[:alert]
  end

  test "should be able to destroy a destroyable supporting page" do
    document = create(:draft_policy)
    supporting_page = create(:supporting_page, document: document, title: "Blah blah")

    delete :destroy, id: supporting_page.id

    assert_redirected_to admin_policy_path(document)
    refute SupportingPage.find_by_id(supporting_page.id)
    assert_equal %{"Blah blah" destroyed.}, flash[:notice]
  end

  test "destroying an indestructible role" do
    document = create(:published_policy)
    supporting_page = create(:supporting_page, document: document, title: "Blah blah")

    delete :destroy, id: supporting_page.id

    assert_redirected_to admin_policy_path(document)
    assert SupportingPage.find_by_id(supporting_page.id)
    assert_equal "Cannot destroy a supporting page that has been published", flash[:alert]
  end

end
