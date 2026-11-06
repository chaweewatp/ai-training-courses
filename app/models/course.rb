class Course < ApplicationRecord
  enum :state, { draft: 0, published: 1 }, default: :draft

  belongs_to :instructor, class_name: "User"
  has_many :chapters, -> { order(:position) }, dependent: :destroy, inverse_of: :course
  has_many :quizzes, through: :chapters
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user
  has_many :certificates, dependent: :destroy

  validates :title, presence: true
  validates :certificate_threshold, numericality: { only_integer: true, in: 0..100 }

  def total_quizzes = quizzes.count
end
