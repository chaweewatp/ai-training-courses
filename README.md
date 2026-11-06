# LearnDeck — AI Training Courses

A Rails app for training courses. Students register and enroll in courses, read
Markdown chapters, and answer keyword-checked quizzes. Instructors (promoted by
admin) author courses and grade answers. Certificates auto-issue when a student
passes the quiz threshold.

## Requirements

- Ruby 3.3+
- Rails 8.0+
- PostgreSQL (or a `DATABASE_URL` to any Postgres)

## Setup

```sh
bundle install
```

Configure the database by creating a `.env` file (gitignored) with a
`DATABASE_URL`, e.g.:

```
DATABASE_URL=postgresql://user:password@host/dbname
```

Without `.env`, the app falls back to local Postgres (`config/database.yml`).

Create and migrate the database, then seed default accounts:

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

(Change these before production.)

## Deploy

Push to GitHub and connect the repo in [Render](https://render.com) — the
`render.yaml` Blueprint provisions the web service. Set `DATABASE_URL` to your
Postgres URL in the Render dashboard.

## Quiz keyword matching

A quiz stores a question and comma-separated keywords. An answer passes if it
contains any keyword (case-insensitive substring). Self-check:

```sh
bin/rails runner script/check_keywords.rb
```
