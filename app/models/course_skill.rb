class CourseSkill < ApplicationRecord
  belongs_to :course
  belongs_to :skill

  validates :course_id, uniqueness: { scope: :skill_id }
  validates :exp, inclusion: { in: Course::EXP_REWARDS }
end
