require "application_system_test_case"

class TimeEntriesTest < ApplicationSystemTestCase
  setup do
    @time_entry = time_entries(:one)
  end

  test "visiting the index" do
    visit time_entries_url
    assert_selector "h1", text: "Time entries"
  end

  test "should create time entry" do
    visit time_entries_url
    click_on "New time entry"

    fill_in "Category", with: @time_entry.category
    fill_in "Duration seconds", with: @time_entry.duration_seconds
    fill_in "Ended at", with: @time_entry.ended_at
    fill_in "Notes", with: @time_entry.notes
    fill_in "Started at", with: @time_entry.started_at
    fill_in "Task name", with: @time_entry.task_name
    fill_in "Ticket ref", with: @time_entry.ticket_ref
    fill_in "User", with: @time_entry.user_id
    click_on "Create Time entry"

    assert_text "Time entry was successfully created"
    click_on "Back"
  end

  test "should update Time entry" do
    visit time_entry_url(@time_entry)
    click_on "Edit this time entry", match: :first

    fill_in "Category", with: @time_entry.category
    fill_in "Duration seconds", with: @time_entry.duration_seconds
    fill_in "Ended at", with: @time_entry.ended_at.to_s
    fill_in "Notes", with: @time_entry.notes
    fill_in "Started at", with: @time_entry.started_at.to_s
    fill_in "Task name", with: @time_entry.task_name
    fill_in "Ticket ref", with: @time_entry.ticket_ref
    fill_in "User", with: @time_entry.user_id
    click_on "Update Time entry"

    assert_text "Time entry was successfully updated"
    click_on "Back"
  end

  test "should destroy Time entry" do
    visit time_entry_url(@time_entry)
    click_on "Destroy this time entry", match: :first

    assert_text "Time entry was successfully destroyed"
  end
end
