class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  private

  def require_admin!
    redirect_to root_path, alert: "Not authorized." unless current_user&.admin?
  end

  def require_instructor!
    redirect_to root_path, alert: "Not authorized." unless current_user&.instructor?
  end
end
