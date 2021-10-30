#!/bin/sh
cd /usr/local/redmine

cp plugins/redmine_wiki_extensions/Gemfile_for_test plugins/redmine_wiki_extensions/Gemfile 
bundle install 
bundle exec rake redmine:plugins:migrate
bundle exec rake redmine:plugins:migrate RAILS_ENV=test

initdb() {
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake redmine:plugins:migrate

    bundle exec rake db:drop RAILS_ENV=test
    bundle exec rake db:create RAILS_ENV=test
    bundle exec rake db:migrate RAILS_ENV=test
    bundle exec rake redmine:plugins:migrate RAILS_ENV=test
}

export DB=postgres

initdb

export DB=mysql

initdb