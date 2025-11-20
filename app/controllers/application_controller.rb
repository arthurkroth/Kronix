class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Devise: allow admins to set role/manager via admin UI only; we don't expose here.
  def configure_permitted_parameters
    # keep as default
  end

  def require_admin!
    unless current_user&.admin?
      redirect_to authenticated_root_path, alert: "Admins only."
    end
  end

  def require_manager_or_admin!
    unless current_user&.manager? || current_user&.admin?
      redirect_to authenticated_root_path, alert: "Managers only."
    end
  end
end