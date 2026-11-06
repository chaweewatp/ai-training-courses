class Certificate < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validates :user_id, uniqueness: { scope: :course_id }

  after_create :award_skills

  private

  def award_skills
    course.course_skills.includes(:skill).each do |cs|
      user_skill = user.user_skills.find_or_create_by!(skill: cs.skill)
      user_skill.update!(exp: user_skill.exp + cs.exp)
    end
  end
end
