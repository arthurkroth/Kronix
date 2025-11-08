class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    #Current running task (if any)
    @active_entry = current_user.time_entries.find_by(ended_at: nil)

    #Finished entries (used for charts)
    finished = current_user.time_entries.where.not(ended_at: nil)

    #---- CHART DATA (HOURS, plain/default) ----
    #SQLite version using JULIANDAY; shows normal Chartkick colors & tooltips
    @by_day = finished
      .where(started_at: 30.days.ago..Time.current)
      .group_by_day(:started_at)
      .sum("CAST((JULIANDAY(ended_at) - JULIANDAY(started_at)) * 24.0 AS FLOAT)")

    @by_category = finished
      .group(:category)
      .sum("CAST((JULIANDAY(ended_at) - JULIANDAY(started_at)) * 24.0 AS FLOAT)")
  end
end
