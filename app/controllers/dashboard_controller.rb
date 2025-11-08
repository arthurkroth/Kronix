class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    # Current running task (if any)
    @active_entry = current_user.time_entries.find_by(ended_at: nil)

    # Finished entries (used for charts)
    finished = current_user.time_entries.where.not(ended_at: nil)

    # Time by day (last 30 days, in hours)
    @by_day = finished
      .where(started_at: 30.days.ago..Time.current)
      .group_by_day(:started_at)
      .sum("CAST((JULIANDAY(ended_at) - JULIANDAY(started_at)) * 24.0 AS FLOAT)")

    # Time by category (all time, in hours)
    @by_category = finished
      .group(:category)
      .sum("CAST((JULIANDAY(ended_at) - JULIANDAY(started_at)) * 24.0 AS FLOAT)")
  end
end
