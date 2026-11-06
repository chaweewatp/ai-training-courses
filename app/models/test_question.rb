class TestQuestion < ApplicationRecord
  belongs_to :course
  has_many :options, class_name: "TestOption", dependent: :destroy, inverse_of: :test_question

  accepts_nested_attributes_for :options, allow_destroy: true,
    reject_if: ->(attrs) { attrs["text"].blank? }

  validates :text, presence: true
  validate :exactly_one_correct_option

  private

  def exactly_one_correct_option
    count = options.reject(&:marked_for_destruction?).count { |o| o.correct && o.text.present? }
    errors.add(:base, "Mark exactly one correct answer") unless count == 1
  end
end
