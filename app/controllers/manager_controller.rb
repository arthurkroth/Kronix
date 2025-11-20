class ManagerController < ApplicationController
  before_action :authenticate_user!
  before_action :require_manager_or_admin!

  def team
    @team_members =
      if current_user.admin?
        User.where.not(id: current_user.id).order(:email)
      else
        current_user.team_members.order(:email)
      end

    # Optional filters for viewing a member's entries
    @member_id = params[:member_id]
    @member    = @member_id.present? ? User.find_by(id: @member_id) : nil

    if @member
      start_date = params[:start_date].presence || 1.month.ago.to_date.to_s
      end_date   = params[:end_date].presence   || Date.current.to_s

      range = Date.parse(start_date).beginning_of_day..Date.parse(end_date).end_of_day

      scope   = @member.time_entries.where(started_at: range)
      @entries = scope.order(started_at: :desc).page(params[:page]).per(10)
    else
      @entries = []
    end
  end
end
