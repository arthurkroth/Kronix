class TimeEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_time_entry, only: %i[ show edit update destroy ]

  #GET /time_entries or /time_entries.json
def index
  @start_date = params[:start_date].presence || 1.month.ago.to_date.to_s
  @end_date   = params[:end_date].presence   || Date.current.to_s

  scope = current_user.time_entries
                      .where(started_at: Date.parse(@start_date).beginning_of_day..Date.parse(@end_date).end_of_day)
  scope = scope.where(category: params[:category]) if params[:category].present?
  @time_entries = scope.order(started_at: :desc).page(params[:page]).per(10)
end

  #GET /time_entries/1 or /time_entries/1.json
  def show
  end

  #GET /time_entries/new
  def new
    @time_entry = TimeEntry.new
  end

  #GET /time_entries/1/edit
  def edit
  end

  #POST /time_entries or /time_entries.json
  def create
    @time_entry = TimeEntry.new(time_entry_params)

    respond_to do |format|
      if @time_entry.save
        format.html { redirect_to @time_entry, notice: "Time entry was successfully created." }
        format.json { render :show, status: :created, location: @time_entry }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  #PATCH/PUT /time_entries/1 or /time_entries/1.json
  def update
    respond_to do |format|
      if @time_entry.update(time_entry_params)
        format.html { redirect_to @time_entry, notice: "Time entry was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @time_entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  #DELETE /time_entries/1 or /time_entries/1.json
  def destroy
    @time_entry.destroy!

    respond_to do |format|
      format.html { redirect_to time_entries_path, notice: "Time entry was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

    #Use callbacks to share common setup or constraints between actions.
  private
  def set_time_entry
    @time_entry = current_user.time_entries.find(params[:id])
  end

    #Only allow a list of trusted parameters through.
  def time_entry_params
    params.require(:time_entry).permit(:ticket_ref, :task_name, :notes, :category, :started_at, :ended_at, :duration_seconds)
  end
end
