class TimeEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_time_entry, only: %i[show edit update destroy]
  before_action :load_projects_for_form, only: %i[new edit]

  def index
    @start_date = params[:start_date].presence || 1.month.ago.to_date.to_s
    @end_date   = params[:end_date].presence   || Date.current.to_s

    scope = current_user.time_entries
                        .where(started_at: Date.parse(@start_date).beginning_of_day..Date.parse(@end_date).end_of_day)
    scope = scope.where(category: params[:category]) if params[:category].present?
    @time_entries = scope.order(started_at: :desc).page(params[:page]).per(10)
  end

  def show; end

  def new
    @time_entry = current_user.time_entries.new
  end

  def edit; end

  def create
    @time_entry = current_user.time_entries.new(time_entry_params)
    assign_project_from_params(@time_entry)

    if @time_entry.save
      redirect_to authenticated_root_path, notice: "Entry created."
    else
      load_projects_for_form
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @time_entry.assign_attributes(time_entry_params)
    assign_project_from_params(@time_entry)

    if @time_entry.save
      redirect_to authenticated_root_path, notice: "Entry saved."
    else
      load_projects_for_form
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @time_entry.destroy
    redirect_to time_entries_path, notice: "Entry deleted."
  end

  private

  def set_time_entry
    @time_entry = current_user.time_entries.find(params[:id])
  end

  def time_entry_params
    params.require(:time_entry).permit(:ticket_ref, :task_name, :notes, :category, :started_at, :ended_at, :duration_seconds, :project_id)
  end

  def load_projects_for_form
    @projects = current_user.projects.order(:name)
  end

  # If category == 'project', allow user to pick an existing project OR type a new one
  def assign_project_from_params(entry)
    if entry.category == "project"
      new_name = params.dig(:time_entry, :new_project_name).to_s.strip
      if new_name.present?
        entry.project = current_user.projects.where(name: new_name).first_or_create!
      elsif entry.project_id.present?
        # already assigned from select field
      else
        entry.project = nil
      end
    else
      entry.project = nil
    end
  end
end
