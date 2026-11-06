class AnswersController < ApplicationController
  before_action :authenticate_user!

  def create
    quiz = Quiz.find(params[:quiz_id])
    answer = current_user.answers.find_or_initialize_by(quiz: quiz)
    answer.text = params[:answer][:text]
    answer.instructor_comment = nil
    answer.correct = quiz.matches?(answer.text)
    answer.save!
    redirect_to course_path(quiz.chapter.course, chapter: quiz.chapter.id),
      notice: answer.correct ? "Correct!" : "Submitted for review."
  end

  def update
    create
  end

  def review
    @answer = Answer.find(params[:id])
    course = @answer.quiz.chapter.course
    redirect_to courses_path, alert: "Not authorized." unless course.instructor == current_user || current_user.admin?

    @answer.update!(
      correct: ActiveModel::Type::Boolean.new.cast(params[:answer][:correct]),
      instructor_comment: params[:answer][:instructor_comment]
    )
    redirect_to manage_course_path(course), notice: "Answer reviewed."
  end
end
