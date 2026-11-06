class ChaptersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :require_owner!

  def new
    @chapter = @course.chapters.build
  end

  def create
    @chapter = @course.chapters.build(chapter_params)
    @chapter.position = @course.chapters.maximum(:position).to_i + 1
    if @chapter.save
      redirect_to @course, notice: "Chapter added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @chapter = @course.chapters.find(params[:id])
  end

  def update
    @chapter = @course.chapters.find(params[:id])
    if @chapter.update(chapter_params)
      redirect_to @course, notice: "Chapter updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course.chapters.find(params[:id]).destroy
    redirect_to @course, notice: "Chapter deleted."
  end

  def toggle_publish
    @chapter = @course.chapters.find(params[:id])
    @chapter.update!(published: !@chapter.published?)
    redirect_to @course, notice: @chapter.published? ? "Chapter published." : "Chapter unpublished."
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def require_owner!
    redirect_to courses_path, alert: "Not authorized." unless @course.instructor == current_user || current_user.admin?
  end

  def chapter_params
    params.require(:chapter).permit(:title, :body, :position)
  end
end
