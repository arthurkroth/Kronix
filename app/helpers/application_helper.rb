module ApplicationHelper
  CATEGORY_LABELS = {
    "task"         => "Task",
    "bau"          => "BAU",
    "project"      => "Project",
    "curve_ball"   => "Curve Ball",

    # Backwards-compat for old data
    "administrative" => "BAU",
    "meeting"        => "Task"
  }.freeze

  # Turn internal category value into nice label for UI
  def human_category(category)
    CATEGORY_LABELS[category.to_s] || category.to_s.titleize
  end

  # Convert float hours into "Xh Ym"
  def format_duration_hours(hours)
    total_minutes = (hours.to_f * 60).round
    h = total_minutes / 60
    m = total_minutes % 60

    parts = []
    parts << "#{h}h" if h.positive?
    parts << "#{m}m" if m.positive? || parts.empty?
    parts.join(" ")
  end
end
