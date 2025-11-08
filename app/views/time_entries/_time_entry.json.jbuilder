json.extract! time_entry, :id, :user_id, :ticket_ref, :task_name, :notes, :category, :started_at, :ended_at, :duration_seconds, :created_at, :updated_at
json.url time_entry_url(time_entry, format: :json)
