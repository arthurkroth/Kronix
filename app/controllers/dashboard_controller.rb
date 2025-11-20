class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    # current running task (if any)
    @active_entry = current_user.time_entries.find_by(ended_at: nil)

    # finished entries (for charts)
    finished = current_user.time_entries.where.not(ended_at: nil)

    # Calculate duration in HOURS as a float using SQLite's JULIANDAY
    hours_sql = "CAST((JULIANDAY(ended_at) - JULIANDAY(started_at)) * 24.0 AS FLOAT)"

    # --- Last 30 days: hours per day ---
    raw_by_day = finished
                 .group_by_day(:started_at, last: 30)
                 .sum(hours_sql)

    # Round to 2 decimal places so we don't get long floats
    @by_day = raw_by_day.transform_values { |hours| hours.round(2) }

    # --- Total time by category ---
    raw_by_category = finished
                      .group(:category)
                      .sum(hours_sql)

    @by_category = raw_by_category.transform_values { |hours| hours.round(2) }
  end
end
