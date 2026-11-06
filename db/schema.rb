# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_07_185100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "answers", force: :cascade do |t|
    t.bigint "quiz_id", null: false
    t.bigint "user_id", null: false
    t.text "text"
    t.boolean "correct", default: false, null: false
    t.text "instructor_comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id", "user_id"], name: "index_answers_on_quiz_id_and_user_id", unique: true
    t.index ["quiz_id"], name: "index_answers_on_quiz_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "certificates", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.datetime "earned_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_certificates_on_course_id"
    t.index ["user_id", "course_id"], name: "index_certificates_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_certificates_on_user_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.string "title", null: false
    t.text "body"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "published", default: false, null: false
    t.index ["course_id"], name: "index_chapters_on_course_id"
  end

  create_table "courses", force: :cascade do |t|
    t.bigint "instructor_id", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "state", default: 0, null: false
    t.integer "certificate_threshold", default: 80, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instructor_id"], name: "index_courses_on_instructor_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["user_id", "course_id"], name: "index_enrollments_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.bigint "chapter_id", null: false
    t.text "text", null: false
    t.string "keywords", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_id"], name: "index_quizzes_on_chapter_id"
  end

  create_table "test_attempts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.integer "test_type", default: 0, null: false
    t.integer "score", default: 0, null: false
    t.integer "total", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_test_attempts_on_course_id"
    t.index ["user_id", "course_id", "test_type"], name: "index_test_attempts_on_user_id_and_course_id_and_test_type", unique: true
    t.index ["user_id"], name: "index_test_attempts_on_user_id"
  end

  create_table "test_options", force: :cascade do |t|
    t.bigint "test_question_id", null: false
    t.text "text", null: false
    t.boolean "correct", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_question_id"], name: "index_test_options_on_test_question_id"
  end

  create_table "test_questions", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.text "text", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_test_questions_on_course_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "answers", "quizzes"
  add_foreign_key "answers", "users"
  add_foreign_key "certificates", "courses"
  add_foreign_key "certificates", "users"
  add_foreign_key "chapters", "courses"
  add_foreign_key "courses", "users", column: "instructor_id"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users"
  add_foreign_key "quizzes", "chapters"
  add_foreign_key "test_attempts", "courses"
  add_foreign_key "test_attempts", "users"
  add_foreign_key "test_options", "test_questions"
  add_foreign_key "test_questions", "courses"
end
