require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "dashboard_test@example.com",
      password: "Password123",
      password_confirmation: "Password123"
    )
  end

  test "guest is redirected to sign in" do
    # No login here – we want to behave as a guest
    get root_url   # assumes: root "dashboard#index"
    assert_redirected_to new_user_session_path
  end

  test "signed-in user can view dashboard" do
    sign_in_as(@user)

    get root_url
    assert_response :success
  end

  private

  # Log in via Devise like a real user
  def sign_in_as(user, password: "Password123")
    post user_session_path, params: {
      user: {
        email: user.email,
        password: password
      }
    }
    follow_redirect! if response.redirect?
  end
end
