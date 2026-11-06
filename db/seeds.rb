admin = User.find_or_initialize_by(email: "admin@example.com")
admin.password = "password123" if admin.new_record?
admin.role = :admin
admin.save!

instructor = User.find_or_initialize_by(email: "instructor@example.com")
instructor.password = "password123" if instructor.new_record?
instructor.role = :instructor
instructor.save!

[ "Python", "JavaScript", "SQL", "Ruby", "Algorithms", "Git" ].each do |name|
  Skill.find_or_create_by!(name: name)
end
