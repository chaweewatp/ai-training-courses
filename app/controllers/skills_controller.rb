class SkillsController < ApplicationController
  before_action :authenticate_user!

  def index
    @skills = Skill.order(:name).includes(:user_skills)
    @exp_by_skill = current_user.user_skills.index_by(&:skill_id)
  end

  def update_name
    if current_user.update(full_name: params[:full_name])
      redirect_to my_skills_path, notice: "Name updated."
    else
      redirect_to my_skills_path, alert: "Could not update name."
    end
  end
end
