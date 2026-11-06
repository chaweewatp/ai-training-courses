class TestOption < ApplicationRecord
  belongs_to :test_question

  validates :text, presence: true
end
