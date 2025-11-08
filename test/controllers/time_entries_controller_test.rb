require "test_helper"

class TimeEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @time_entry = time_entries(:one)
  end

  test "should get index" do
    get time_entries_url
    assert_response :success
  end

  test "should get new" do
    get new_time_entry_url
    assert_response :success
  end

  test "should create time_entry" do
    assert_difference("TimeEntry.count") do
      post time_entries_url, params: { time_entry: { category: @time_entry.category, duration_seconds: @time_entry.duration_seconds, ended_at: @time_entry.ended_at, notes: @time_entry.notes, started_at: @time_entry.started_at, task_name: @time_entry.task_name, ticket_ref: @time_entry.ticket_ref, user_id: @time_entry.user_id } }
    end

    assert_redirected_to time_entry_url(TimeEntry.last)
  end

  test "should show time_entry" do
    get time_entry_url(@time_entry)
    assert_response :success
  end

  test "should get edit" do
    get edit_time_entry_url(@time_entry)
    assert_response :success
  end

  test "should update time_entry" do
    patch time_entry_url(@time_entry), params: { time_entry: { category: @time_entry.category, duration_seconds: @time_entry.duration_seconds, ended_at: @time_entry.ended_at, notes: @time_entry.notes, started_at: @time_entry.started_at, task_name: @time_entry.task_name, ticket_ref: @time_entry.ticket_ref, user_id: @time_entry.user_id } }
    assert_redirected_to time_entry_url(@time_entry)
  end

  test "should destroy time_entry" do
    assert_difference("TimeEntry.count", -1) do
      delete time_entry_url(@time_entry)
    end

    assert_redirected_to time_entries_url
  end
end
