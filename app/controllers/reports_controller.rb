require "prawn"
require "prawn/table"

class ReportsController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_user!

  def show
    if params[:user_id].present?
      if current_user.manager? || current_user.admin?
        @report_user = User.find(params[:user_id])
      else
        redirect_to authenticated_root_path, alert: "Not authorized." and return
      end
    else
      @report_user = current_user
    end

    @period = params[:period].presence_in(%w[weekly monthly]) || "weekly"

    @range =
      if @period == "weekly"
        Date.current.beginning_of_week..Date.current.end_of_week
      else
        Date.current.beginning_of_month..Date.current.end_of_month
      end

    base = @report_user.time_entries
                       .where(
                         started_at: @range.begin.beginning_of_day..
                                     @range.end.end_of_day
                       )
                       .where.not(ended_at: nil)

    @by_day = base.group_by_day(:started_at)
                  .sum("CAST((JULIANDAY(ended_at) - JULIANDAY(started_at)) * 24.0 AS FLOAT)")

    @by_category = base.group(:category)
                       .sum("CAST((JULIANDAY(ended_at) - JULIANDAY(started_at)) * 24.0 AS FLOAT)")

    @total_hours = @by_day.values.sum.round(2)

    @entries = base.includes(:project).order(started_at: :asc)
    @entries_page = @entries.page(params[:page]).per(20)

    respond_to do |format|
      format.html
      format.pdf { send_report_pdf }
    end
  end

  private

  def send_report_pdf
    pdf = build_pdf_report
    send_data pdf.render,
              filename: pdf_filename,
              type: "application/pdf",
              disposition: "attachment"
  end

  def pdf_filename
    prefix = @period == "weekly" ? "WeeklyTaskReport" : "MonthlyTaskReport"
    date_suffix = Date.current.strftime("%d%m%Y")
    "#{prefix}#{date_suffix}.pdf"
  end

  def build_pdf_report
    Prawn::Document.new do |doc|
      doc.text "Kronix – #{@period.capitalize} report", size: 18, style: :bold
      doc.move_down 10
      doc.text "User: #{@report_user.email}"
      doc.text "Period: #{@range.begin.to_date} to #{@range.end.to_date}"
      doc.text "Generated: #{Time.current.strftime('%Y-%m-%d %H:%M')}"
      doc.move_down 10
      doc.text "Total hours: #{human_duration(@total_hours)}", style: :bold
      doc.move_down 10

      if @entries.any?
        data = [ [ "Started", "Ended", "Duration", "Category", "Ticket", "Task", "Project" ] ]
        @entries.each do |e|
          data << [
            e.started_at&.strftime("%Y-%m-%d %H:%M"),
            e.ended_at&.strftime("%Y-%m-%d %H:%M"),
            human_duration(e.hours),
            human_category(e.category),
            e.ticket_ref,
            e.task_name,
            e.project&.name
          ]
        end

        doc.table(data, header: true, row_colors: %w[FFFFFF F0F0F0])
      else
        doc.text "No entries for this period."
      end
    end
  end

  def human_duration(hours)
    total_minutes = (hours.to_f * 60).round
    h = total_minutes / 60
    m = total_minutes % 60

    parts = []
    parts << "#{h}h" if h.positive?
    parts << "#{m}m" if m.positive? || parts.empty?
    parts.join(" ")
  end
end
