require 'test_helper'

class FeedbackControllerTest < ActionController::TestCase
  test "should get staff" do
    get :staff
    assert_response :success
  end

end
