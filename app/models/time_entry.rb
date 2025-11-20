class TimeEntry < ApplicationRecord
  belongs_to :user
  belongs_to :project, optional: true

  def active?
    ended_at.nil?
  end

  def hours
    return 0 unless ended_at && started_at
    ((ended_at - started_at) / 3600.0).round(2)
  end
end