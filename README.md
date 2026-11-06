# SkillUp — AI Training Courses

A Rails app for training courses. Students register and enroll in courses, read
Markdown chapters, answer keyword-checked quizzes, and take pre/post
multiple-choice tests. Instructors (promoted by admin) author courses and grade
answers. Certificates auto-issue and award skill experience points.

## Features

- **Roles**: student, instructor (admin-promoted), admin.
- **Courses**: draft/published, with per-chapter publishing (students only see
  published chapters).
- **Quizzes**: short-answer, checked against comma-separated keywords
  (case-insensitive substring, OR).
- **Pre/post tests**: shared multiple-choice question bank, questions/options in
  Markdown.
- **Certificates**: auto-issued when quiz pass % **and** post-test % reach the
  threshold; printable HTML.
- **Skills**: admin-managed skill list; courses reward skill exp (1/2/3/5/8/13);
  students level up per skill (level N = N×5 exp, up to level 10).

## Requirements

- Ruby 3.3+
- Rails 8.1+
- PostgreSQL (or a `DATABASE_URL` to any Postgres)

## Setup

```sh
bundle install
```

Create a `.env` file (gitignored) with a `DATABASE_URL`:

```
DATABASE_URL=postgresql://user:password@host/dbname
```

Without `.env`, the app falls back to local Postgres.

```sh
bin/rails db:create db:migrate db:seed
```

## Run

```sh
bin/rails server
```

Open http://localhost:3000

## Test accounts

| Role       | Email                  | Password       |
|------------|------------------------|----------------|
| Admin      | admin@example.com      | password123    |
| Instructor | instructor@example.com | password123    |

Seeds also create sample skills: Python, JavaScript, SQL, Ruby, Algorithms, Git.

(Change these before production.)

## Deploy

Push to GitHub and connect the repo in [Render](https://render.com). The
`render.yaml` Blueprint provisions the web service. Set these env vars in the
Render dashboard:

- `DATABASE_URL` — your Postgres URL
- `SECRET_KEY_BASE` — `bin/rails secret`

## Quiz keyword matching self-check

```sh
bin/rails runner script/check_keywords.rb
```
