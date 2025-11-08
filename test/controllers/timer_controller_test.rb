require "test_helper"

class TimerControllerTest < ActionDispatch::IntegrationTest
  test "should get start" do
    get timer_start_url
    assert_response :success
  end

  test "should get stop" do
    get timer_stop_url
    assert_response :success
  end
end
