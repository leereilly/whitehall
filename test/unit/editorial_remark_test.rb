require 'test_helper'

class EditorialRemarkTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    editorial_remark = build(:editorial_remark)
    assert editorial_remark.valid?
  end

  test "should not be valid without a document" do
    editorial_remark = build(:editorial_remark, document: nil)
    refute editorial_remark.valid?
  end

  test "should not be valid without a body" do
    editorial_remark = build(:editorial_remark, body: nil)
    refute editorial_remark.valid?
  end

  test "should not be valid without an author" do
    editorial_remark = build(:editorial_remark, author: nil)
    refute editorial_remark.valid?
  end
end