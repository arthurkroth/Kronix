class User < ApplicationRecord
  # Devise modules (your list may already match this)
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  # Roles – Rails 8 style enum
  # 0 = user, 1 = manager, 2 = admin
  enum :role, { user: 0, manager: 1, admin: 2 }

  # Relationships
  has_many :time_entries, dependent: :destroy
  has_many :projects,     dependent: :destroy

  # Manager/team hierarchy
  belongs_to :manager, class_name: "User", optional: true
  has_many   :team_members, class_name: "User", foreign_key: "manager_id"

  # Scopes
  scope :managers,     -> { where(role: :manager) }
  scope :admins,       -> { where(role: :admin) }
  scope :normal_users, -> { where(role: :user) }

  # Helper for dropdowns
  def full_label
    "#{email} (#{role})"
  end
  
  # Password complexity (optional – OWASP recommends longer over “weird rules”)
  validate :password_complexity
  private

  def password_complexity
    return if password.blank?

    unless password.match?(/\d/) && password.match?(/[A-Za-z]/)
      errors.add :password, "must include at least one letter and one number"
    end
  end

end
