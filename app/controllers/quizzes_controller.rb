class QuizzesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chapter
  before_action :require_owner!

  def new
    @quiz = @chapter.quizzes.build
  end

  def create
    @quiz = @chapter.quizzes.build(quiz_params)
    if @quiz.save
      redirect_to @chapter.course, notice: "Quiz added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @quiz = @chapter.quizzes.find(params[:id])
  end

  def update
    @quiz = @chapter.quizzes.find(params[:id])
    if @quiz.update(quiz_params)
      redirect_to @chapter.course, notice: "Quiz updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @chapter.quizzes.find(params[:id]).destroy
    redirect_to @chapter.course, notice: "Quiz deleted."
  end

  private

  def set_chapter
    @chapter = Chapter.find(params[:chapter_id])
  end

  def require_owner!
    course = @chapter.course
    redirect_to courses_path, alert: "Not authorized." unless course.instructor == current_user || current_user.admin?
  end

  def quiz_params
    params.require(:quiz).permit(:text, :keywords)
  end
end
