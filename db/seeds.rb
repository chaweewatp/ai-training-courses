admin = User.find_or_initialize_by(email: "admin@example.com")
admin.password = "password123" if admin.new_record?
admin.role = :admin
admin.save!

instructor = User.find_or_initialize_by(email: "instructor@example.com")
instructor.password = "password123" if instructor.new_record?
instructor.role = :instructor
instructor.save!
