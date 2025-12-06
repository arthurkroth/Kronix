class TimeEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_time_entry, only: %i[show edit update destroy]

  def index
    @start_date = params[:start_date].presence || 1.month.ago.to_date.to_s
    @end_date   = params[:end_date].presence   || Date.current.to_s
    @category   = params[:category].presence

    range = Date.parse(@start_date).beginning_of_day..Date.parse(@end_date).end_of_day

    @time_entries = current_user.time_entries
                                .includes(:project)
                                .where(started_at: range)
                                .order(started_at: :desc)

    @time_entries = @time_entries.where(category: @category) if @category.present?
    @time_entries = @time_entries.page(params[:page]).per(20)
  end

  def show
  end

  def new
    @time_entry = current_user.time_entries.new
    load_projects
  end

  def edit
    load_projects
  end

  def create
    @time_entry = current_user.time_entries.new(time_entry_params)
    assign_project_from_params(@time_entry)

    if @time_entry.save
      redirect_to @time_entry, notice: "Time entry was successfully created."
    else
      load_projects
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @time_entry.assign_attributes(time_entry_params)
    assign_project_from_params(@time_entry)

    if @time_entry.save
      redirect_to dashboard_show_path, notice: "Time entry updated."
    else
      load_projects
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @time_entry.destroy
    redirect_to time_entries_path, notice: "Time entry deleted."
  end

  private

  def set_time_entry
    @time_entry = current_user.time_entries.find(params[:id])
  end

  def time_entry_params
    params.require(:time_entry).permit(
      :ticket_ref,
      :task_name,
      :description,
      :category,
      :started_at,
      :ended_at,
      :project_id,
      :new_project_name  # virtual attribute from attr_accessor
    )
  end

  def load_projects
    # All projects this user owns, ordered by name
    @projects = current_user.projects.order(:name)
  end

  def assign_project_from_params(entry)
    project_id = params.dig(:time_entry, :project_id).presence
    new_name   = params.dig(:time_entry, :new_project_name).to_s.strip

    if new_name.present?
      # Either re-use an existing project with that name, or create a new one
      project = current_user.projects.find_or_create_by!(name: new_name)
      entry.project = project
    elsif project_id
      entry.project = current_user.projects.find_by(id: project_id)
    else
      entry.project = nil
    end
  end
end
