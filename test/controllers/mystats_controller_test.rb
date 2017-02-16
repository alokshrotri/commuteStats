require 'test_helper'

class MystatsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get mystats_show_url
    assert_response :success
  end

end
