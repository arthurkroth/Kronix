class TimerController < ApplicationController
  before_action :authenticate_user!

  # Start a task (auto-stops any running one)
  def start
    ActiveRecord::Base.transaction do
      # 1)Stop the current active one if exists
      if (active = current_user.time_entries.find_by(ended_at: nil))
        stop_and_save(active)
      end

      # Fill gap since last finished task as "administrative"
      fill_admin_gap!

      # Start the new entry
      current_user.time_entries.create!(
        started_at: Time.current,
        category: params[:category].presence || "bau"
      )
    end

    redirect_to authenticated_root_path, notice: "Timer started."
  end

  # Stop the current task and send user to edit page to fill details
  def stop
    if (active = current_user.time_entries.find_by(ended_at: nil))
      stop_and_save(active)
      redirect_to edit_time_entry_path(active), notice: "Timer stopped. Please fill in details."
    else
      redirect_to authenticated_root_path, alert: "No active task to stop."
    end
  end

  private

  def stop_and_save(entry)
    entry.ended_at = Time.current
    entry.duration_seconds = (entry.ended_at - entry.started_at).to_i
    entry.save!
  end

  # Auto-create an Administrative entry from the last finished end_time up to now
  def fill_admin_gap!
    now = Time.current

    # last finished entry for this user
    last_finished = current_user.time_entries
                                .where.not(ended_at: nil)
                                .order(ended_at: :desc)
                                .first
    return unless last_finished

    gap_start = last_finished.ended_at
    gap_end   = now
    return unless gap_start < gap_end

    # Guardrails: only fill if the last end was today and gap <= 2 hours
    return unless gap_start.to_date == now.to_date
    return if (gap_end - gap_start) > 1.hours

    current_user.time_entries.create!(
      started_at: gap_start,
      ended_at:   gap_end,
      duration_seconds: (gap_end - gap_start).to_i,
      category: "administrative",
      task_name: "Administrative",
      notes: "Auto-filled gap between tasks"
    )
  end
end
