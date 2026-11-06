class CoursesController < ApplicationController
  before_action :authenticate_user!, except: [ :index ]
  before_action :set_course, only: [ :show, :edit, :update, :destroy, :enroll, :manage, :certificate, :review_student, :pre_test, :post_test, :submit_test ]
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
    @owner = @course.instructor == current_user || current_user.admin?
    @chapters = @owner ? @course.chapters : @course.chapters.published
    @chapter = @chapters.find_by(id: params[:chapter]) || @chapters.first
    @progress = student_progress if @chapter && @enrolled
  end

  def new
    require_instructor!
    @course = current_user.courses.build
  end

  def create
    require_instructor!
    @course = current_user.courses.build(course_params)
    if @course.save
      sync_course_skills
      redirect_to @course, notice: "Course created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      sync_course_skills
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

  def pre_test
    render_test(:pre)
  end

  def post_test
    render_test(:post)
  end

  def submit_test
    test_type = params[:test_type]
    unless [ "pre", "post" ].include?(test_type)
      redirect_to @course, alert: "Invalid test."
      return
    end
    redirect_to @course, alert: "Enroll to take the test." unless current_user.enrolled_courses.exists?(@course.id)

    questions = @course.test_questions.includes(:options)
    answers = params[:answers] || {}
    score = questions.count do |q|
      chosen_id = answers[q.id.to_s]
      chosen_id.present? && q.options.any? { |o| o.id.to_s == chosen_id.to_s && o.correct }
    end
    total = questions.count
    attempt = current_user.test_attempts.find_or_initialize_by(course: @course, test_type: test_type)
    attempt.update!(score: score, total: total)
    redirect_to @course, notice: "You scored #{score}/#{total} on the #{test_type}-test."
  end

  private

  def render_test(test_type)
    unless current_user.enrolled_courses.exists?(@course.id) || @course.instructor == current_user || current_user.admin?
      redirect_to @course, alert: "Enroll to take the test."
      return
    end
    @test_type = test_type
    @questions = @course.test_questions.includes(:options)
    @attempt = current_user.test_attempts.find_by(course: @course, test_type: test_type)
    render :test
  end

  def course_params
    params.require(:course).permit(:title, :description, :state, :certificate_threshold)
  end

  def sync_course_skills
    selected_ids = params[:skill_ids] || []
    exp_by_id = params[:skill_exp] || {}
    @course.course_skills.destroy_all
    selected_ids.each do |skill_id|
      exp = exp_by_id[skill_id.to_s].to_i
      exp = Course::EXP_REWARDS.first unless Course::EXP_REWARDS.include?(exp)
      @course.course_skills.create!(skill_id: skill_id, exp: exp)
    end
  end

  def set_course
    @course = Course.includes(chapters: :quizzes).find(params[:id])
  end

  def require_owner!
    redirect_to courses_path, alert: "Not authorized." unless @course.instructor == current_user || current_user.admin?
  end

  def eligible?
    @course.eligible?(current_user)
  end

  def student_progress
    quizzes = @chapter.quizzes.includes(:answers)
    total = quizzes.count
    passed = quizzes.count { |q| q.answers.any? { |a| a.user_id == current_user.id && a.correct } }
    { passed: passed, total: total }
  end
end
