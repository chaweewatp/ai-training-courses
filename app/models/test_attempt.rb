class TestAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :course

  enum :test_type, { pre: 0, post: 1 }

  validates :user_id, uniqueness: { scope: [ :course_id, :test_type ] }

  def percent
    total.zero? ? 0 : (score.to_f / total * 100).round
  end
end
