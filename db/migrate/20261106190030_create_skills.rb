# frozen_string_literal: true

class CreateSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :skills do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :skills, :name, unique: true

    create_table :user_skills do |t|
      t.references :user, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true
      t.integer :exp, null: false, default: 0
      t.timestamps
    end
    add_index :user_skills, [ :user_id, :skill_id ], unique: true

    create_table :course_skills do |t|
      t.references :course, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true
      t.integer :exp, null: false, default: 1
      t.timestamps
    end
    add_index :course_skills, [ :course_id, :skill_id ], unique: true
  end
end
