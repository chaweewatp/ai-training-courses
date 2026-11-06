# frozen_string_literal: true

class AddPublishedToChapters < ActiveRecord::Migration[8.1]
  def change
    add_column :chapters, :published, :boolean, null: false, default: false
  end
end
