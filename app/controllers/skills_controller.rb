class SkillsController < ApplicationController
  before_action :authenticate_user!

  def index
    @skills = Skill.order(:name).includes(:user_skills)
    @exp_by_skill = current_user.user_skills.index_by(&:skill_id)
  end
end
