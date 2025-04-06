require "test_helper"

class DynamicsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dynamics_index_url
    assert_response :success
  end

  test "should get show" do
    get dynamics_show_url
    assert_response :success
  end

  test "should get new" do
    get dynamics_new_url
    assert_response :success
  end

  test "should get edit" do
    get dynamics_edit_url
    assert_response :success
  end
end
