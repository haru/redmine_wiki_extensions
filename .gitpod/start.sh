#!/bin/sh

REDMINEDIR=/workspace/redmine
cd $(dirname "$0") || exit
GITPODDIR=$(pwd)
cd ..
BASEDIR=$(pwd)
PLUGIN_NAME=$(basename "$BASEDIR")

cd "$REDMINEDIR" || exit
sed "s/__PLUGIN__NAME/$PLUGIN_NAME/" "$GITPODDIR"/gitpod.code-workspace > "$REDMINEDIR"/gitpod.code-workspace
gem install ruby-debug-ide
bundle install --path vendor/bundle
bundle exec rake db:migrate
bundle exec rake redmine:plugins:migrate
bundle exec rake db:migrate RAILS_ENV=test
bundle exec rake redmine:plugins:migrate RAILS_ENV=test