class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { student: 0, instructor: 1, admin: 2 }, default: :student

  has_many :courses, foreign_key: :instructor_id, dependent: :restrict_with_error
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :answers, dependent: :destroy
  has_many :certificates, dependent: :destroy

  def instructor? = role == "instructor"
  def admin? = role == "admin"

  def generate_reset_link!
    token = set_reset_password_token!
    "/users/password/edit?reset_password_token=#{token}"
  end
end
