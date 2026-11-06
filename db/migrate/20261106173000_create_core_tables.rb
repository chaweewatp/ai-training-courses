# frozen_string_literal: true

class CreateCoreTables < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.references :instructor, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.integer :state, null: false, default: 0
      t.integer :certificate_threshold, null: false, default: 80
      t.timestamps
    end

    create_table :chapters do |t|
      t.references :course, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :quizzes do |t|
      t.references :chapter, null: false, foreign_key: true
      t.text :text, null: false
      t.string :keywords, null: false, default: ""
      t.timestamps
    end

    create_table :answers do |t|
      t.references :quiz, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :text
      t.boolean :correct, null: false, default: false
      t.text :instructor_comment
      t.timestamps
    end
    add_index :answers, [ :quiz_id, :user_id ], unique: true

    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.timestamps
    end
    add_index :enrollments, [ :user_id, :course_id ], unique: true

    create_table :certificates do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.datetime :earned_at, null: false
      t.timestamps
    end
    add_index :certificates, [ :user_id, :course_id ], unique: true
  end
end
