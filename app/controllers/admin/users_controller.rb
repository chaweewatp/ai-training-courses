class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @users = User.order(:created_at)
  end

  def update_role
    user = User.find(params[:id])
    role = params[:role]
    if %w[student instructor].include?(role)
      user.update!(role: role)
      redirect_to admin_users_path, notice: "Updated #{user.email} to #{role}."
    else
      redirect_to admin_users_path, alert: "Invalid role."
    end
  end

  def reset_password
    user = User.find(params[:id])
    flash[:reset_url] = request.base_url + user.generate_reset_link!
    redirect_to admin_users_path
  end
end
