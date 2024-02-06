#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
./bin/rails assets:precompile
./bin/rails assets:clean

# ./bin/rake RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1 db:reset
./bin/rails db:migrate:down VERSION='20240201115929' #Create user preferences
# ./bin/rails db:migrate
# ./bin/rails db:seed_fu
