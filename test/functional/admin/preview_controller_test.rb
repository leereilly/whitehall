require 'test_helper'

class Admin::PreviewControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "renders the body param using govspeak into a document body template" do
    post :preview, body: "# gov speak"
    assert_select "section.document_view .body h1", "gov speak"
  end
end