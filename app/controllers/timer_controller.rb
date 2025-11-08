class TimerController < ApplicationController
  before_action :authenticate_user!

  # Start a task (auto-stops any running one)
  def start
    ActiveRecord::Base.transaction do
      # Stop current active one, if exists
      if (active = current_user.time_entries.find_by(ended_at: nil))
        stop_and_save(active)
      end

      # Start a new blank entry (user fills details when stopped)
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
end
