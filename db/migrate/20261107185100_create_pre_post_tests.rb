# frozen_string_literal: true

class CreatePrePostTests < ActiveRecord::Migration[8.1]
  def change
    create_table :test_questions do |t|
      t.references :course, null: false, foreign_key: true
      t.text :text, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :test_options do |t|
      t.references :test_question, null: false, foreign_key: true
      t.text :text, null: false
      t.boolean :correct, null: false, default: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :test_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer :test_type, null: false, default: 0
      t.integer :score, null: false, default: 0
      t.integer :total, null: false, default: 0
      t.timestamps
    end
    add_index :test_attempts, [ :user_id, :course_id, :test_type ], unique: true
  end
end
