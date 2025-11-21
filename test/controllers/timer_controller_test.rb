require "test_helper"

class TimerControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "timer_test@example.com",
      password: "Password123",
      password_confirmation: "Password123"
    )
  end

  test "start creates a new time entry and redirects to edit page" do
    sign_in_as(@user)

    assert_difference("TimeEntry.count", 1) do
      post start_timer_url, params: { category: "BAU" }
    end

    assert_response :redirect
    entry = TimeEntry.last
    assert_equal @user.id, entry.user_id
    assert_equal "BAU", entry.category
    assert_nil entry.ended_at
  end

  test "stop ends the running entry and redirects" do
    entry = @user.time_entries.create!(
      started_at: Time.zone.now - 30.minutes,
      category:   "BAU"
    )

    sign_in_as(@user)

    post stop_timer_url

    assert_response :redirect
    entry.reload
    assert_not_nil entry.ended_at
  end

  private

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
