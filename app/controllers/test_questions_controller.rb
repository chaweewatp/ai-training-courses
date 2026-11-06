class TestQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :require_owner!

  def index
    @test_questions = @course.test_questions.includes(:options)
  end

  def new
    @test_question = @course.test_questions.build
    build_blank_options(@test_question)
  end

  def create
    @test_question = @course.test_questions.build(test_question_params)
    if @test_question.save
      redirect_to course_test_questions_path(@course), notice: "Question added."
    else
      build_blank_options(@test_question)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @test_question = @course.test_questions.includes(:options).find(params[:id])
    build_blank_options(@test_question)
  end

  def update
    @test_question = @course.test_questions.find(params[:id])
    if @test_question.update(test_question_params)
      redirect_to course_test_questions_path(@course), notice: "Question updated."
    else
      build_blank_options(@test_question)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course.test_questions.find(params[:id]).destroy
    redirect_to course_test_questions_path(@course), notice: "Question deleted."
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def require_owner!
    redirect_to courses_path, alert: "Not authorized." unless @course.instructor == current_user || current_user.admin?
  end

  def build_blank_options(question)
    (4 - question.options.size).times { question.options.build }
  end

  def test_question_params
    params.require(:test_question).permit(
      :text, :position,
      options_attributes: [ :id, :text, :correct, :_destroy ]
    )
  end
end
