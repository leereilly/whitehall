require "test_helper"

class MinisterialRolesControllerTest < ActionController::TestCase

  should_show_published_documents_associated_with :ministerial_role, :policies
  should_show_published_documents_associated_with :ministerial_role, :publications
  should_show_published_documents_associated_with :ministerial_role, :consultations

  test "shows only published news and speeches associated with ministerial role" do
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role)
    published_speech = create(:published_speech, role_appointment: role_appointment)
    draft_speech = create(:draft_speech, role_appointment: role_appointment)
    published_news_article = create(:published_news_article, ministerial_roles: [ministerial_role])
    draft_news_article = create(:draft_news_article, ministerial_roles: [ministerial_role])

    get :show, id: ministerial_role

    assert_select_object(published_speech)
    refute_select_object(draft_speech)
    assert_select_object(published_news_article)
    refute_select_object(draft_news_article)
  end

  test "shows only news and speeches associated with ministerial role" do
    ministerial_role = create(:ministerial_role)
    another_ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role)
    another_role_appointment = create(:role_appointment, role: another_ministerial_role)
    published_speech = create(:published_speech, role_appointment: role_appointment)
    another_published_speech = create(:published_speech, role_appointment: another_role_appointment)
    published_news_article = create(:published_news_article, ministerial_roles: [ministerial_role])
    another_published_news_article = create(:published_news_article, ministerial_roles: [another_ministerial_role])

    get :show, id: ministerial_role

    assert_select ".news_and_speeches" do
      assert_select_object(published_speech)
      refute_select_object(another_published_speech)
      assert_select_object(published_news_article)
      refute_select_object(another_published_news_article)
    end
  end

  test "shows most recent news and speeches at the top" do
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role)
    newer_speech = create(:published_speech, role_appointment: role_appointment, published_at: 1.hour.ago)
    older_speech = create(:published_speech, role_appointment: role_appointment, published_at: 4.hours.ago)
    newer_news_article = create(:published_news_article, ministerial_roles: [ministerial_role], published_at: 2.hours.ago)
    older_news_article = create(:published_news_article, ministerial_roles: [ministerial_role], published_at: 3.hours.ago)

    get :show, id: ministerial_role

    assert_equal [newer_speech, newer_news_article, older_news_article, older_speech], assigns[:announcements]
  end

  test "should not display an empty published speeches section" do
    ministerial_role = create(:ministerial_role)

    get :show, id: ministerial_role

    refute_select ".news_and_speeches"
  end

  test "shows minister's picture if available" do
    minister = create(:person, image: File.open(File.join(Rails.root, 'test', 'fixtures', 'minister-of-funk.jpg')))
    role_appointment = create(:ministerial_role_appointment, person: minister)
    get :show, id: role_appointment.role.id

    assert_select "img[src='#{minister.image.url}']"
  end

  test "shows placeholder picture if minister has none" do
    role_appointment = create(:ministerial_role_appointment)
    get :show, id: role_appointment.role.id

    assert_select "img[src$='blank-person.png']"
  end
end