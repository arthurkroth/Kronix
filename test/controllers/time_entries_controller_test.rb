require "test_helper"

class TimeEntriesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "entries_test@example.com",
      password: "Password123",
      password_confirmation: "Password123"
    )

    sign_in_as(@user)

    @entry = @user.time_entries.create!(
      started_at: Time.zone.now - 1.hour,
      ended_at:   Time.zone.now,
      category:   "BAU",
      task_name:  "Existing entry from test"
    )
  end

  test "should get index" do
    get time_entries_url
    assert_response :success
  end

  test "should get new" do
    get new_time_entry_url
    assert_response :success
  end

  test "should create time entry" do
    assert_difference("TimeEntry.count", 1) do
      post time_entries_url, params: {
        time_entry: {
          started_at: Time.zone.now - 30.minutes,
          ended_at:   Time.zone.now,
          category:   "Task",
          task_name:  "Created in controller test"
        }
      }
    end
    assert_response :redirect
  end

  test "should show time entry" do
    get time_entry_url(@entry)
    assert_response :success
  end

  test "should get edit" do
    get edit_time_entry_url(@entry)
    assert_response :success
  end

  test "should update time entry" do
    patch time_entry_url(@entry), params: {
      time_entry: { task_name: "Updated task name" }
    }
    assert_response :redirect
    @entry.reload
    assert_equal "Updated task name", @entry.task_name
  end

  test "should destroy time entry" do
    assert_difference("TimeEntry.count", -1) do
      delete time_entry_url(@entry)
    end
    assert_response :redirect
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
