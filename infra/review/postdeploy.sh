#!/bin/sh

SCHEMA=/app/db/structure-review.sql bundle exec bin/rails db:structure:load
bundle exec bin/rails db:seed
bundle exec bin/rails db:migrate
