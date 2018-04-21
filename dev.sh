#!/usr/bin/env bash
set -e
# set -x # Uncomment to debug

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${MY_DIR}

${MY_DIR}/setup.sh

bundle exec rake db:create db:migrate db:test:prepare db:seed
RAILS_ENV=test bundle exec rake db:create db:migrate
bundle exec foreman start -f Procfile.dev
