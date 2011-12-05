require "test_helper"

class SupportingPagesControllerTest < ActionController::TestCase
  test "index links to supporting pages" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, title: "supporting-page-title", document: policy)
    get :index, policy_id: policy.document_identity
    path = policy_supporting_page_path(policy.document_identity, supporting_page)
    assert_select supporting_pages_selector do
      assert_select_object supporting_page do
        assert_select "a[href=#{path}]"
        assert_select ".title", text: "supporting-page-title"
      end
    end
  end

  test "index only shows supporting pages for the parent policy" do
    policy = create(:published_policy)
    other_supporting_page = create(:supporting_page)
    get :index, policy_id: policy.document_identity
    refute_select_object other_supporting_page
  end

  test "index doesn't display an empty list if there aren't any supporting pages" do
    policy = create(:published_policy)
    get :index, policy_id: policy.document_identity
    refute_select "#{supporting_pages_selector} ul"
  end

  test "shows link to policy overview" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_select "a[href='#{policy_path(policy.document_identity)}#policy_view']", text: policy.title
  end

  test "shows link to each policy section in the markdown" do
    policy = create(:published_policy, body: %{
## First Section

Some content

## Another Bit

More content

## Final Part

That's all
})

    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_select "ol#policy_sections" do
      assert_select "li a[href='#{policy_path(policy.document_identity, anchor: 'first-section')}']", text: 'First Section'
      assert_select "li a[href='#{policy_path(policy.document_identity, anchor: 'another-bit')}']", text: 'Another Bit'
      assert_select "li a[href='#{policy_path(policy.document_identity, anchor: 'final-part')}']", text: 'Final Part'
    end
  end

  test "shows the body using govspeak markup" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, document: policy, body: "body-in-govspeak")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_select ".body", text: "body-in-html"
  end

  test "doesn't show supporting page if parent isn't published" do
    policy = create(:draft_policy)
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_response :not_found
  end

  test "should show inapplicable nations" do
    policy = create(:published_policy)
    northern_ireland_inapplicability = policy.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = policy.nation_inapplicabilities.create!(nation: Nation.scotland)
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_select inapplicable_nations_selector do
      assert_select "p", "This policy does not apply to Northern Ireland and Scotland."
      assert_select_object northern_ireland_inapplicability do
        assert_select "a[href='http://northern-ireland.com/']"
      end
      refute_select_object scotland_inapplicability
    end
  end

  test "should explain that policy applies to the whole of the UK" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_select inapplicable_nations_selector do
      assert_select "p", "This policy applies to the whole of the UK."
    end
  end

  test "show displays related published publications" do
    related_publication = create(:published_publication, title: "Voting Patterns")
    policy = create(:published_policy, documents_related_with: [related_publication])
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_select related_publications_selector do
      assert_select_object related_publication
    end
  end

  test "show excludes related unpublished publications" do
    related_publication = create(:draft_publication, title: "Voting Patterns")
    policy = create(:published_policy, documents_related_with: [related_publication])
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    refute_select related_publications_selector
  end

  test "show displays related published consultations" do
    related_consultation = create(:published_consultation, title: "Consultation on Voting Patterns")
    policy = create(:published_policy, documents_related_with: [related_consultation])
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_select related_consultations_selector do
      assert_select_object related_consultation
    end
  end

  test "show excludes related unpublished consultations" do
    related_consultation = create(:draft_consultation, title: "Consultation on Voting Patterns")
    policy = create(:published_policy, documents_related_with: [related_consultation])
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    refute_select related_consultations_selector
  end

  test "show displays related news articles" do
    related_news_article = create(:published_news_article, title: "News about Voting Patterns")
    policy = create(:published_policy, documents_related_with: [related_news_article])
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_select related_news_articles_selector do
      assert_select_object related_news_article
    end
  end

  test "show excludes related unpublished news articles" do
    related_news_article = create(:draft_news_article, title: "News about Voting Patterns")
    policy = create(:published_policy, documents_related_with: [related_news_article])
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    refute_select related_news_articles_selector
  end

  test "show lists supporting pages when there are some" do
    policy = create(:published_policy)
    first_supporting_page = create(:supporting_page, document: policy)
    second_supporting_page = create(:supporting_page, document: policy)
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_select ".policy_view nav" do
      assert_select "a[href='#{policy_supporting_page_path(policy.document_identity, first_supporting_page)}']", text: first_supporting_page.title
      assert_select "a[href='#{policy_supporting_page_path(policy.document_identity, second_supporting_page)}']", text: second_supporting_page.title
    end
  end

  test "should display the published document" do
    document_identity = create(:document_identity)
    create(:archived_policy, document_identity: document_identity)
    policy = create(:published_policy, document_identity: document_identity)
    create(:draft_policy, document_identity: document_identity)
    supporting_page = create(:supporting_page, document: policy)
    get :show, policy_id: document_identity, id: supporting_page

    assert_response :success
    assert_equal policy, assigns[:policy]
  end

  test "should link to policy areas from within the metadata navigation" do
    first_policy_area = create(:policy_area)
    second_policy_area = create(:policy_area)
    policy = create(:published_policy, policy_areas: [first_policy_area, second_policy_area])
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_select "#{metadata_nav_selector} a.policy_area", text: first_policy_area.name
    assert_select "#{metadata_nav_selector} a.policy_area", text: second_policy_area.name
  end

  test "should link to organisations from within the metadata navigation" do
    first_org = create(:organisation)
    second_org = create(:organisation)
    policy = create(:published_policy, organisations: [first_org, second_org])
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_select "#{metadata_nav_selector} a.organisation", text: first_org.name
    assert_select "#{metadata_nav_selector} a.organisation", text: second_org.name
  end

  test "should link to ministers from within the metadata navigation" do
    role = create(:ministerial_role)
    appointment = create(:role_appointment, person: create(:person, name: "minister-name"), role: role)
    policy = create(:published_policy, ministerial_roles: [appointment.role])
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_select "#{metadata_nav_selector} a.minister", text: "minister-name"
  end

  test "should be compatible with and render the policies/show template" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, document: policy)
    get :show, policy_id: policy.document_identity, id: supporting_page
    assert_equal policy, assigns(:policy)
    assert_equal supporting_page, assigns(:document)
    assert_template "policies/show"
  end

  test "show displays recently changed documents related to the policy" do
    publication = create(:published_publication)
    consultation = create(:published_consultation)
    news_article = create(:published_news_article)
    speech = create(:published_speech)
    policy = create(:published_policy,
      documents_related_with: [publication, consultation, news_article, speech]
    )
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_select "#recently-changed" do
      assert_select_object publication
      assert_select_object consultation
      assert_select_object news_article
      assert_select_object speech
    end
  end

  test "show orders recently changed documents related to the policy most recent first" do
    publication = create(:published_publication, published_at: 4.weeks.ago)
    consultation = create(:published_consultation, published_at: 1.weeks.ago)
    news_article = create(:published_news_article, published_at: 3.weeks.ago)
    speech = create(:published_speech, published_at: 2.weeks.ago)
    policy = create(:published_policy,
      documents_related_with: [publication, consultation, news_article, speech]
    )
    supporting_page = create(:supporting_page, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_page

    assert_equal [consultation, speech, news_article, publication], assigns[:recently_changed_documents]
  end

end