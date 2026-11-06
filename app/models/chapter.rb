class Chapter < ApplicationRecord
  belongs_to :course, inverse_of: :chapters
  has_many :quizzes, dependent: :destroy

  validates :title, presence: true
end
