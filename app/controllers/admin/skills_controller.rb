class Admin::SkillsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @skills = Skill.order(:name)
  end

  def new
    @skill = Skill.new
  end

  def create
    @skill = Skill.new(skill_params)
    if @skill.save
      redirect_to admin_skills_path, notice: "Skill created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @skill = Skill.find(params[:id])
  end

  def update
    @skill = Skill.find(params[:id])
    if @skill.update(skill_params)
      redirect_to admin_skills_path, notice: "Skill updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Skill.find(params[:id]).destroy
    redirect_to admin_skills_path, notice: "Skill deleted."
  end

  private

  def skill_params
    params.require(:skill).permit(:name)
  end
end
