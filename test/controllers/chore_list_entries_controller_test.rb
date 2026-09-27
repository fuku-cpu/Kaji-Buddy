require "test_helper"

class ChoreListEntriesControllerTest < ActionDispatch::IntegrationTest
  test "should get guide" do
    get chore_list_entries_guide_url
    assert_response :success
  end

  test "should get new" do
    get chore_list_entries_new_url
    assert_response :success
  end

  test "should get create" do
    get chore_list_entries_create_url
    assert_response :success
  end
end
