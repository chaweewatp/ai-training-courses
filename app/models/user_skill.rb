class UserSkill < ApplicationRecord
  belongs_to :user
  belongs_to :skill

  validates :user_id, uniqueness: { scope: :skill_id }

  def level
    Skill.level_for(exp)
  end
end
