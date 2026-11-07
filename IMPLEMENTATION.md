# SkillUp — Implementation

Rails app for training courses. Students register, enroll, study Markdown
chapters, and answer keyword-checked quizzes. Instructors (promoted by admin)
author courses and grade answers. Pre/post multiple-choice tests measure
learning. Certificates auto-issue and award skill experience.

## Stack

- Rails 8.1.x, Ruby 3.3.x, PostgreSQL
- Devise (email login; no `:confirmable`; `:recoverable` used only for the admin
  password-reset token, no email sending)
- `kramdown` (GFM) + `rouge` for Markdown rendering + syntax highlighting;
  tables supported; `MathJax` (CDN) renders `$…$` / `$$…$$` math
- Bootstrap 5.3 (CDN) with native light/dark via `data-bs-theme`, teal/emerald accent
- Deploy: GitHub → Render (web service + `DATABASE_URL`/`SECRET_KEY_BASE` env vars)

## Roles & auth

- `User` with `role` enum: `student` (default) / `instructor` / `admin`.
- Admin promotes/demotes via `Admin::UsersController#index`; `admin` set by seed.
- Password reset: admin generates a one-time token + URL (no email).

## Data model

- `Course` — `instructor`, `state` (draft/published), `certificate_threshold` (%).
- `Chapter` — `course`, `title`, `body` (Markdown), `position`, `published`.
- `Quiz` — `chapter`, `text`, `keywords` (comma-separated). One quiz = one question.
- `Answer` — one per (quiz, student), overwritten on retry; `correct`,
  `instructor_comment`.
- `Enrollment` — join user↔course.
- `Certificate` — user↔course, `earned_at`; `after_create` awards skill exp.
- `TestQuestion` / `TestOption` — multiple-choice (Markdown, exactly-one-correct),
  shared by pre- and post-test.
- `TestAttempt` — user↔course, `test_type` (pre/post), `score`, `total`.
- `Skill` — global list (admin CRUD). Levels mocked to 10 (`N * 5` cumulative exp).
- `UserSkill` — user's exp per skill.
- `CourseSkill` — course rewards a skill with `exp` ∈ {1,2,3,5,8,13}.

## Quiz logic

Substring, case-insensitive, OR over keywords (`answer.downcase.include?(kw)`).
Keyword match sets `correct = true`; instructor can override to incorrect + comment;
student re-answers by overwriting.

## Chapter publish

`Chapter.published` (default false). Instructor publishes one chapter at a time;
students see/access only published chapters (no auto-unlock).

## Pre/post tests

One question bank per course used for both pre-test and post-test. MCQs rendered
as radio buttons; submission scores and stores a `TestAttempt` (retake overwrites).
Result shows score only (correct answers not revealed).

## Certificate

Eligibility = **quiz pass % ≥ threshold AND post-test % ≥ threshold**
(whichever exists; a course with only one still works). The instructor issues a
certificate to an eligible student from the course manage page; it then shows in
the student's certificate menu. The student can also self-issue from the
certificate page when eligible. Rendered as printable HTML. Issuing a
certificate adds each `CourseSkill` exp to the student's `UserSkill`.

## Skills & leveling

- Admin manages the global skill list (`Admin::SkillsController`).
- Instructor selects skills + exp reward per course in the course form.
- Student "My Skills" page shows exp, level, and progress to the next level.
- Level `N` = `N * 5` cumulative exp (mock to level 10): L1=5, L2=10, … L10=50.

## Screens / routes

- Public: catalog (published courses) + enroll.
- Student: course player (chapters + code copy + quizzes), pre/post tests,
  certificate, "My Skills".
- Instructor: course/chapter/quiz/test-question authoring, course management
  (progress summary → per-student review), publish toggles.
- Admin: user list (promote/demote, reset password), skill list.

## Deploy

`render.yaml` declares the web service. No `config/credentials.yml.enc` — secrets
come from env vars: `DATABASE_URL` (Postgres) and `SECRET_KEY_BASE`. Build:
`bundle install && bin/rails assets:precompile`, predeploy `db:migrate`.

## Checks

- `bin/rails runner script/check_keywords.rb` — keyword matching self-check.
- `bin/brakeman`, `bin/rubocop`, `bin/importmap audit` run in CI.
