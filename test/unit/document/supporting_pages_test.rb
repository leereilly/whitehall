require "test_helper"

class Document::SupportingPagesTest < ActiveSupport::TestCase
  test "#destroy should also remove the supporting pages" do
    document = create(:draft_policy)
    supporting_page = create(:supporting_page, document: document)
    document.destroy
    refute SupportingPage.find_by_id(supporting_page.id)
  end
end
