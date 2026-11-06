class Skill < ApplicationRecord
  has_many :user_skills, dependent: :destroy
  has_many :course_skills, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  # Cumulative exp required to reach each level (mocked up to level 10).
  LEVELS = (1..10).map { |n| n * 5 }.freeze

  def self.level_for(exp)
    LEVELS.count { |threshold| exp >= threshold }
  end

  def self.next_threshold(exp)
    LEVELS.find { |threshold| threshold > exp }
  end
end
