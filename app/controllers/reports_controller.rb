class ReportsController < ApplicationController
  before_action :authenticate_user!

  def show
    # Who is the report for?
    if params[:user_id].present?
      # Only managers/admins can view someone else's report
      if current_user.manager? || current_user.admin?
        @report_user = User.find(params[:user_id])
      else
        redirect_to authenticated_root_path, alert: "Not authorized." and return
      end
    else
      @report_user = current_user
    end

    # Period: weekly or monthly, default to weekly
    @period = params[:period].presence_in(%w[weekly monthly]) || "weekly"

    range =
      if @period == "weekly"
        Date.current.beginning_of_week..Date.current.end_of_week
      else
        Date.current.beginning_of_month..Date.current.end_of_month
      end

    base = @report_user.time_entries
                       .where(
                         started_at: range.begin.beginning_of_day..
                                     range.end.end_of_day
                       )
                       .where.not(ended_at: nil)

    # SQLite version using JULIANDAY (same style as your dashboard)
    @by_day = base.group_by_day(:started_at)
                  .sum("CAST((JULIANDAY(ended_at) - JULIANDAY(started_at)) * 24.0 AS FLOAT)")

    @by_category = base.group(:category)
                       .sum("CAST((JULIANDAY(ended_at) - JULIANDAY(started_at)) * 24.0 AS FLOAT)")

    @total_hours = @by_day.values.sum.round(2)
  end
end
