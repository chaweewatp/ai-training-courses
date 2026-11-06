# Self-check for quiz keyword matching. Run: bin/rails runner script/check_keywords.rb
quiz = Quiz.new(keywords: "60, sixty")
cases = {
  "60" => true,
  "60 seconds" => true,
  "1 mins = 60 secs" => true,
  "Sixty" => true,
  "forty two" => false
}
cases.each do |input, expected|
  actual = quiz.matches?(input)
  raise "FAIL: #{input.inspect} expected #{expected}, got #{actual}" unless actual == expected
end
puts "OK: all #{cases.size} keyword cases passed"
