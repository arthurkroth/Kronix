require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "dashboard_user@example.com",
      password: "Password123",
      password_confirmation: "Password123"
    )
  end

  test "guest is redirected to sign in" do
    get dashboard_show_url
    assert_redirected_to new_user_session_path
  end

  test "signed-in user can view dashboard" do
    sign_in @user

    get dashboard_show_url
    assert_response :success
    assert_select "h1", /Time Tracker/
  end
end
