require 'test_helper'

class NewsArticlesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_render_a_list_of :news_articles, :first_published_at
  should_show_related_policies_and_policy_areas_for :news_article
  should_show_the_countries_associated_with :news_article

  test "shows published news article" do
    news_article = create(:published_news_article)
    get :show, id: news_article.document_identity
    assert_response :success
  end

  test "renders the news article body using govspeak" do
    news_article = create(:published_news_article, body: "body-in-govspeak")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, id: news_article.document_identity

    assert_select ".body", text: "body-in-html"
  end

  test "renders the news article notes to editors using govspeak" do
    news_article = create(:published_news_article, notes_to_editors: "notes-to-editors-in-govspeak")
    Govspeak::Document.stubs(:to_html).returns("\n")
    Govspeak::Document.stubs(:to_html).with("notes-to-editors-in-govspeak").returns("notes-to-editors-in-html")

    get :show, id: news_article.document_identity

    assert_select "#{notes_to_editors_selector}", text: /notes-to-editors-in-html/
  end

  test "excludes the notes to editors section if they're empty" do
    news_article = create(:published_news_article, notes_to_editors: "")
    get :show, id: news_article.document_identity
    refute_select "#{notes_to_editors_selector}"
  end

  test "shows when news article was first published" do
    news_article = create(:published_news_article, published_at: 10.days.ago)

    get :show, id: news_article.document_identity

    assert_select ".meta .metadata" do
      assert_select ".first_published_at[title='#{news_article.first_published_at.iso8601}']"
    end
  end

  test "shows when updated news article was last updated" do
    news_article = create(:published_news_article, published_at: 10.days.ago)

    editor = create(:departmental_editor)
    updated_news_article = news_article.create_draft(editor)
    updated_news_article.change_note = "change-note"
    updated_news_article.publish_as(editor, force: true)

    get :show, id: updated_news_article.document_identity

    assert_select ".meta .metadata" do
      assert_select ".published_at[title='#{updated_news_article.published_at.iso8601}']"
    end
  end

  test "show displays the image for the news article" do
    portas_review_jpg = fixture_file_upload('portas-review.jpg')
    news_article = create(:published_news_article, image: portas_review_jpg, image_alt_text: 'candid photo')
    get :show, id: news_article.document_identity

    assert_select ".document_view" do
      assert_select "figure.image img[src='#{news_article.image_url}'][alt='#{news_article.image_alt_text}']"
    end
  end

  test "show displays the image caption for the news article" do
    portas_review_jpg = fixture_file_upload('portas-review.jpg')
    news_article = create(:published_news_article, image: portas_review_jpg, image_alt_text: 'candid photo', image_caption: "image caption")

    get :show, id: news_article.document_identity

    assert_select ".document_view" do
      assert_select "figure.image figcaption", "image caption"
    end
  end

  test "show only displays image if there is one" do
    news_article = create(:published_news_article, image: nil)

    get :show, id: news_article.document_identity

    assert_select ".document_view" do
      refute_select ".img img"
    end
  end
end
