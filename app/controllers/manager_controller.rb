class ManagerController < ApplicationController
  before_action :authenticate_user!
  before_action :require_manager_or_admin!

  # GET /team
  def team
    # Team members this manager/admin can see
    @team_members =
      if current_user.admin?
        User.where.not(id: current_user.id).order(:email)
      else
        current_user.team_members.order(:email)
      end

    # Users available to be added as team members (normal users with no manager)
    @available_users =
      if current_user.admin?
        User.where(role: :user).order(:email)
      else
        User.where(role: :user, manager_id: nil).order(:email)
      end

    # Optional selection to view someone’s entries
    @member_id = params[:member_id]
    @member    = @member_id.present? ? User.find_by(id: @member_id) : nil

    if @member
      start_date = params[:start_date].presence || 1.month.ago.to_date.to_s
      end_date   = params[:end_date].presence   || Date.current.to_s

      range = Date.parse(start_date).beginning_of_day..Date.parse(end_date).end_of_day

      scope = @member.time_entries.includes(:project).where(started_at: range)
      @entries_page = scope.order(started_at: :desc).page(params[:page]).per(10)
    else
      @entries_page = []
    end
  end

  # POST /team/add_member
  def add_member
    user = User.find_by(id: params[:user_id])

    if user.nil? || !user.user?
      redirect_to manager_team_path, alert: "Invalid user selected." and return
    end

    # Only allow attaching users without a manager, unless admin
    if !current_user.admin? && user.manager_id.present? && user.manager_id != current_user.id
      redirect_to manager_team_path, alert: "User already belongs to another manager." and return
    end

    user.update!(manager_id: current_user.id)
    redirect_to manager_team_path, notice: "Added #{user.email} to your team."
  end

  # DELETE /team/remove_member/:id
  def remove_member
    user =
      if current_user.admin?
        User.find(params[:id])
      else
        current_user.team_members.find(params[:id])
      end

    user.update!(manager_id: nil)
    redirect_to manager_team_path, notice: "Removed #{user.email} from your team."
  end
end
