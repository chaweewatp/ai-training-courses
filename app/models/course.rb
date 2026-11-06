class Course < ApplicationRecord
  enum :state, { draft: 0, published: 1 }, default: :draft

  belongs_to :instructor, class_name: "User"
  has_many :chapters, -> { order(:position) }, dependent: :destroy, inverse_of: :course
  has_many :quizzes, through: :chapters
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user
  has_many :certificates, dependent: :destroy
  has_many :test_questions, -> { order(:position) }, dependent: :destroy
  has_many :test_attempts, dependent: :destroy

  validates :title, presence: true
  validates :certificate_threshold, numericality: { only_integer: true, in: 0..100 }

  def total_quizzes = quizzes.count

  def passed_quiz_count(user)
    quizzes.joins(:answers).where(answers: { user_id: user.id, correct: true }).count
  end

  def quiz_percent(user)
    return 0 if total_quizzes.zero?
    (passed_quiz_count(user).to_f / total_quizzes * 100).round
  end

  def post_test_percent(user)
    attempt = test_attempts.find_by(user: user, test_type: :post)
    return 0 if attempt.nil?
    attempt.percent
  end

  def eligible?(user)
    quiz_total = total_quizzes
    post_total = test_questions.count
    return false if quiz_total.zero? && post_total.zero?

    quiz_ok = quiz_total.zero? || quiz_percent(user) >= certificate_threshold
    post_ok = post_total.zero? || post_test_percent(user) >= certificate_threshold
    quiz_ok && post_ok
  end
end
