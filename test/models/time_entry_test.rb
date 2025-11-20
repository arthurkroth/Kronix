require "test_helper"

class TimeEntryTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test_user@example.com",
      password: "Password123",
      password_confirmation: "Password123"
    )
  end

  test "is valid with basic attributes" do
    entry = TimeEntry.new(
      user: @user,
      started_at: Time.zone.parse("2025-11-20 09:00"),
      ended_at:   Time.zone.parse("2025-11-20 10:00"),
      category:   "BAU",
      ticket:     "T-1234",
      task_name:  "Test task"
    )

    assert entry.valid?, "time entry with basic attributes should be valid"
  end

  test "is invalid without a user" do
    entry = TimeEntry.new(
      started_at: Time.zone.now,
      ended_at:   Time.zone.now + 1.hour,
      category:   "Task"
    )

    assert_not entry.valid?, "time entry without user should be invalid"
    assert_includes entry.errors[:user], "must exist"
  end
end
