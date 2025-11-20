class TimeEntry < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true

  # Virtual attributes used by the form
  attr_accessor :new_project_name, :description

  # Calculates the duration in decimal hours
  def hours
    return 0.0 unless started_at && ended_at
    ((ended_at - started_at) / 3600.0).round(2)
  end
end
