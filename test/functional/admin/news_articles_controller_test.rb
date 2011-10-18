require 'test_helper'

class Admin::NewsArticlesControllerTest < ActionController::TestCase
  setup do
    @user = login_as "George"
  end

  test 'is an admin controller' do
    assert @controller.is_a?(Admin::BaseController), "the controller should have the behaviour of an Admin::BaseController"
  end

  test 'creating should create a new news article' do
    first_topic = create(:topic)
    second_topic = create(:topic)
    first_org = create(:organisation)
    second_org = create(:organisation)
    attributes = attributes_for(:news_article)

    post :create, document: attributes.merge(
      topic_ids: [first_topic.id, second_topic.id],
      organisation_ids: [first_org.id, second_org.id]
    )

    created_news_article = NewsArticle.last
    assert_equal attributes[:title], created_news_article.title
    assert_equal attributes[:body], created_news_article.body
    assert_equal [first_topic, second_topic], created_news_article.topics
    assert_equal [first_org, second_org], created_news_article.organisations
  end

  test 'creating should take the writer to the news article page' do
    post :create, document: attributes_for(:news_article)

    assert_redirected_to admin_news_article_path(NewsArticle.last)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'creating with invalid data should leave the writer in the news article editor' do
    attributes = attributes_for(:news_article)
    post :create, document: attributes.merge(title: '')

    assert_equal attributes[:body], assigns(:document).body, "the valid data should not have been lost"
    assert_template "documents/new"
  end

  test 'creating with invalid data should set an alert in the flash' do
    attributes = attributes_for(:news_article)
    post :create, document: attributes.merge(title: '')

    assert_equal 'There are some problems with the document', flash.now[:alert]
  end

  test 'updating should save modified document attributes' do
    first_topic = create(:topic)
    second_topic = create(:topic)
    news_article = create(:news_article, topics: [first_topic])

    put :update, id: news_article.id, document: { title: "new-title", body: "new-body", topic_ids: [second_topic.id] }

    saved_news_article = news_article.reload
    assert_equal "new-title", saved_news_article.title
    assert_equal "new-body", saved_news_article.body
    assert_equal [second_topic], saved_news_article.topics
  end

  test 'updating should take the writer to the news article page' do
    news_article = create(:news_article)
    put :update, id: news_article.id, document: {title: 'new-title', body: 'new-body'}

    assert_redirected_to admin_news_article_path(news_article)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'updating with invalid data should not save the news article' do
    attributes = attributes_for(:news_article)
    news_article = create(:news_article, attributes)
    put :update, id: news_article.id, document: attributes.merge(title: '')

    assert_equal attributes[:title], news_article.reload.title
    assert_template "documents/edit"
    assert_equal 'There are some problems with the document', flash.now[:alert]
  end

  test 'updating a stale news article should render edit page with conflicting news article' do
    news_article = create(:draft_news_article)
    lock_version = news_article.lock_version
    news_article.update_attributes!(title: "new title")

    put :update, id: news_article, document: news_article.attributes.merge(lock_version: lock_version)

    assert_template 'edit'
    conflicting_news_article = news_article.reload
    assert_equal conflicting_news_article, assigns[:conflicting_document]
    assert_equal conflicting_news_article.lock_version, assigns[:document].lock_version
    assert_equal %{This document has been saved since you opened it}, flash[:alert]
  end

  test "cancelling a new news article takes the user to the list of drafts" do
    get :new
    assert_select "a[href=#{admin_documents_path}]", text: /cancel/i, count: 1
  end

  test "cancelling an existing news article takes the user to that news article" do
    draft_news_article = create(:draft_news_article)
    get :edit, id: draft_news_article
    assert_select "a[href=#{admin_news_article_path(draft_news_article)}]", text: /cancel/i, count: 1
  end

  test 'updating a submitted news article with bad data should show errors' do
    attributes = attributes_for(:submitted_news_article)
    submitted_news_article = create(:submitted_news_article, attributes)
    put :update, id: submitted_news_article, document: attributes.merge(title: '')

    assert_template 'edit'
  end

  test "show the 'add supporting document' button for an unpublished document" do
    draft_news_article = create(:draft_news_article)

    get :show, id: draft_news_article

    assert_select "a[href='#{new_admin_document_supporting_document_path(draft_news_article)}']"
  end

  test "don't show the 'add supporting document' button for a published news article" do
    published_news_article = create(:published_news_article)

    get :show, id: published_news_article

    assert_select "a[href='#{new_admin_document_supporting_document_path(published_news_article)}']", count: 0
  end

  test "should render the content using govspeak markup" do
    draft_news_article = create(:draft_news_article, body: "body-in-govspeak")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, id: draft_news_article

    assert_select ".body", text: "body-in-html"
  end
end