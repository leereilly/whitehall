require 'test_helper'

class Admin::PoliciesControllerTest < ActionController::TestCase

  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :policy
  should_allow_creating_of :policy
  should_allow_editing_of :policy

  should_allow_organisations_for :policy
  should_allow_ministerial_roles_for :policy
  should_allow_association_between_countries_and :policy
  should_be_rejectable :policy
  should_be_publishable :policy
  should_be_force_publishable :policy
  should_be_able_to_delete_a_document :policy
  should_link_to_public_version_when_published :policy
  should_not_link_to_public_version_when_not_published :policy
  should_prevent_modification_of_unmodifiable :policy

  test "show the 'add supporting page' button for an unpublished document" do
    draft_policy = create(:draft_policy)

    get :show, id: draft_policy

    assert_select "a[href='#{new_admin_document_supporting_page_path(draft_policy)}']"
  end

  test "don't show the 'add supporting page' button for a published policy" do
    published_policy = create(:published_policy)

    get :show, id: published_policy

    refute_select "a[href='#{new_admin_document_supporting_page_path(published_policy)}']"
  end

  test "show lists supporting pages when there are some" do
    draft_policy = create(:draft_policy)
    first_supporting_page = create(:supporting_page, document: draft_policy)
    second_supporting_page = create(:supporting_page, document: draft_policy)

    get :show, id: draft_policy

    assert_select ".supporting_pages" do
      assert_select_object(first_supporting_page) do
        assert_select "a[href='#{admin_supporting_page_path(first_supporting_page)}'] span.title", text: first_supporting_page.title
      end
      assert_select_object(second_supporting_page) do
        assert_select "a[href='#{admin_supporting_page_path(second_supporting_page)}'] span.title", text: second_supporting_page.title
      end
    end
  end

  test "doesn't show supporting pages list when empty" do
    draft_policy = create(:draft_policy)

    get :show, id: draft_policy

    refute_select ".supporting_pages .supporting_page"
  end

  test "new should display policy areas field" do
    get :new

    assert_select "form#document_new" do
      assert_select "select[name*='document[policy_area_ids]']"
    end
  end

  test "create should associate policy areas with policy" do
    first_policy_area = create(:policy_area)
    second_policy_area = create(:policy_area)
    attributes = attributes_for(:policy)

    post :create, document: attributes.merge(
      policy_area_ids: [first_policy_area.id, second_policy_area.id]
    )

    assert policy = Policy.last
    assert_equal [first_policy_area, second_policy_area], policy.policy_areas
  end

  test "edit should display policy areas field" do
    policy = create(:policy)

    get :edit, id: policy

    assert_select "form#document_edit" do
      assert_select "select[name*='document[policy_area_ids]']"
    end
  end

  test "update should associate policy areas with policy" do
    first_policy_area = create(:policy_area)
    second_policy_area = create(:policy_area)

    policy = create(:policy, policy_areas: [first_policy_area])

    put :update, id: policy, document: {
      policy_area_ids: [second_policy_area.id]
    }

    policy.reload
    assert_equal [second_policy_area], policy.policy_areas
  end

  test "update should remove all policy areas if none specified" do
    policy_area = create(:policy_area)

    policy = create(:policy, policy_areas: [policy_area])

    put :update, id: policy, document: {}

    policy.reload
    assert_equal [], policy.policy_areas
  end

  test "updating should retain associations to related documents" do
    policy = create(:draft_policy)
    publication = create(:draft_publication, related_policies: [policy])
    assert policy.related_documents.include?(publication), "policy and publication should be related"

    put :update, id: policy, document: {title: "another title"}

    policy.reload
    assert policy.related_documents.include?(publication), "polcy and publication should still be related"
  end

  test "show does not display image for document types that do not allow one" do
    policy = create(:policy)

    get :show, id: policy

    refute_select ".image img"
  end
end
