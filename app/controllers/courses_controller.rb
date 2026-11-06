class CoursesController < ApplicationController
  before_action :authenticate_user!, except: [ :index ]
  before_action :set_course, only: [ :show, :edit, :update, :destroy, :enroll, :manage, :certificate, :review_student ]
  before_action :require_owner!, only: [ :edit, :update, :destroy, :manage, :review_student ]

  def index
    @courses = Course.published.includes(:instructor).order(:created_at)
  end

  def mine
    @enrolled = current_user.enrolled_courses.includes(:instructor).order(:created_at)
    @owned = current_user.courses.includes(:instructor).order(:created_at)
  end

  def show
    unless @course.published? || @course.instructor == current_user || current_user.admin?
      redirect_to courses_path, alert: "Course not available."
      return
    end
    @enrolled = current_user.enrolled_courses.exists?(@course.id)
    @chapter = @course.chapters.find_by(id: params[:chapter]) || @course.chapters.first
    @progress = student_progress if @chapter
  end

  def new
    require_instructor!
    @course = current_user.courses.build
  end

  def create
    require_instructor!
    @course = current_user.courses.build(course_params)
    if @course.save
      redirect_to @course, notice: "Course created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      redirect_to @course, notice: "Course updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course.destroy
    redirect_to my_courses_path, notice: "Course deleted."
  end

  def enroll
    unless @course.published?
      redirect_to courses_path, alert: "Course not available."
      return
    end
    Enrollment.find_or_create_by!(user: current_user, course: @course)
    redirect_to @course, notice: "Enrolled!"
  end

  def manage
    @students = @course.students.distinct
  end

  def review_student
    @student = User.find(params[:user_id])
    @answers = @student.answers.joins(quiz: :chapter).where(chapters: { course_id: @course.id })
      .includes(quiz: :chapter).order("chapters.position", "quizzes.id")
    @passed = @answers.where(correct: true).count
  end

  def certificate
    @certificate = current_user.certificates.find_by(course: @course)
    if @certificate.nil? && eligible?
      @certificate = current_user.certificates.create!(course: @course, earned_at: Time.current)
    end
    unless @certificate
      redirect_to @course, alert: "Not eligible yet."
      nil
    end
  end

  private

  def course_params
    params.require(:course).permit(:title, :description, :state, :certificate_threshold)
  end

  def set_course
    @course = Course.includes(chapters: :quizzes).find(params[:id])
  end

  def require_owner!
    redirect_to courses_path, alert: "Not authorized." unless @course.instructor == current_user || current_user.admin?
  end

  def eligible?
    return false unless @course.total_quizzes.positive?
    passed = @course.quizzes.joins(:answers)
      .where(answers: { user_id: current_user.id, correct: true }).count
    passed.to_f / @course.total_quizzes * 100 >= @course.certificate_threshold
  end

  def student_progress
    quizzes = @chapter.quizzes.includes(:answers)
    total = quizzes.count
    passed = quizzes.count { |q| q.answers.any? { |a| a.user_id == current_user.id && a.correct } }
    { passed: passed, total: total }
  end
end
