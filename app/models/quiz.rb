class Quiz < ApplicationRecord
  belongs_to :chapter
  has_many :answers, dependent: :destroy

  validates :text, presence: true

  def keywords_list
    keywords.split(",").map(&:strip).reject(&:empty?)
  end

  def matches?(answer_text)
    haystack = answer_text.to_s.downcase
    keywords_list.any? { |kw| haystack.include?(kw.downcase) }
  end
end
