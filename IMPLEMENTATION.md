# Implementation Plan — AI Training Courses

Ruby on Rails web app for training courses. Students register, enroll in courses, and
answer quiz questions. Instructors (promoted by admin) author courses and grade answers.
Certificates are auto-issued when a student passes the quiz threshold.

## Stack

- Rails 8.0.x, Ruby 3.3.x, PostgreSQL
- Devise (email login, no confirmable/recoverable)
- `redcarpet` + `rouge` for Markdown rendering + syntax highlighting
- Deploy: GitHub (public) → Render Blueprint (`render.yaml`)

## UI / design

- Server-rendered ERB + Hotwire/Turbo (no SPA).
- Bootstrap 5.3+ (CDN or `importmap`) with native light/dark via `data-bs-theme`.
- Accent theme: teal/emerald, layered via CSS variables overriding `--bs-primary`.
- Theme toggle button → `localStorage` + `prefers-color-scheme` default.
- Code blocks: `rouge` highlight + copy-to-clipboard button (vanilla JS).
- Reference mockup: `prototype/index.html` (catalog, player, manage, certificate, admin).

---

## 1. Roles & auth

- One `users` table, `role` enum: `student` (default) / `instructor` / `admin`.
- Devise auth, login key = email. **No** `:confirmable`, **no** `:recoverable`.
- Admin promotes/demotes via `User#index` (`student ↔ instructor`). `admin` set by seed only.
- Password reset (no email): admin generates a one-time token + URL, hands it to the user,
  user opens it and sets a new password.

Models:

```
User
  role            enum(student/instructor/admin, default: student)
  reset_token     string, nullable   # admin-generated password reset
  reset_token_at  datetime, nullable
  has_many :courses (as instructor)
  has_many :enrollments
  has_many :answers
  has_many :certificates
```

## 2. Data model

```
Course
  instructor_id     FK users
  state             enum(draft/published, default: draft)
  certificate_threshold  integer (percent, e.g. 80)
  has_many :chapters
  has_many :enrollments
  has_many :certificates

Chapter
  course_id
  body              text (Markdown)
  position          integer
  has_many :quizzes

Quiz                    # one quiz = one question
  chapter_id
  text              string (question)
  keywords          string (comma-separated, e.g. "60, sixty")
  has_many :answers

Answer                  # one per (quiz, student), overwritten on retry
  quiz_id
  user_id
  text              string
  correct           boolean
  instructor_comment text, nullable
  # unique index on [quiz_id, user_id]

Enrollment              # instant, tracks progress
  user_id
  course_id
  # unique index on [user_id, course_id]

Certificate             # auto-issued
  user_id
  course_id
  earned_at          datetime
  # unique index on [user_id, course_id]
```

## 3. Quiz logic

- Substring, case-insensitive: split `keywords` on comma, trim, downcase both sides,
  `answer.downcase.include?(kw)` — OR over keywords.
- Flow 3: keyword match sets `correct = true` automatically; instructor can override to
  `incorrect` + comment; student re-answers by overwriting their `Answer`.
- Progress: `passed = course.quizzes.where(answers: { correct: true })` effectively
  `Answer.where(correct: true)` for that student. Percent = `passed / total_quizzes_in_course`.

## 4. Certificate

- Auto-issued when `passed / total >= certificate_threshold`.
- Rendered as printable HTML page (browser "Print → Save as PDF"). No server-side PDF.

## 5. Screens / routes

- Public: course catalog (`Course#index`, `published` only) + `Enroll` button.
- Student: course view → chapters (Markdown with copy-to-clipboard code blocks) → quizzes.
- Instructor: `Course` CRUD (draft→publish), `Chapter` CRUD, `Quiz` CRUD.
- Course management: summary table (student, `passed/total → %`, cert status) → drill-down
  into a student's per-quiz answers for override + comments.
- Admin: `User#index` promote/demote + "reset password" token.

## 6. Deploy (Render Blueprint)

`render.yaml`:

- `web` service: build `bundle install && ./bin/rails assets:precompile`,
  predeploy `./bin/rails db:migrate`, start `./bin/rails server`.
- `postgresql` database → injects `DATABASE_URL`.

Push to GitHub, connect repo in Render, Blueprint provisions both services.

---

## Build order

1. `rails new` (Postgres) → Devise → `User` + role enum.
2. Models + migrations: `Course`, `Chapter`, `Quiz`, `Answer`, `Enrollment`, `Certificate`.
3. Keyword matching + quiz submit/retry flow.
4. Enrollment + progress + certificate auto-issue.
5. Instructor course/chapter/quiz authoring (Markdown + highlight + copy button).
6. Course management summary + drill-down review screen.
7. Admin user index + password-reset token.
8. `render.yaml` + deploy.
