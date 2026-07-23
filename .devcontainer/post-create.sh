#!/bin/sh
cd `dirname $0`
cd ..
BASEDIR=`pwd`
PLUGIN_NAME=`basename $BASEDIR`

if [ ! -f ~/.bashrc ]; then
    cd ~/
    tar xfz /.home.tgz
    cd $BASEDIR 
fi

rm -f /usr/local/redmine/.rubocop.yml 

curl -fsSL https://claude.ai/install.sh | bash
curl -fsSL https://opencode.ai/install | bash

if [ -f .devcontainer/redmine.code-workspace ] && grep -q '"/usr/local/redmine/plugins/dummy"' .devcontainer/redmine.code-workspace; then
    sed -i.bak "s|\"/usr/local/redmine/plugins/dummy\"|\"/usr/local/redmine/plugins/$PLUGIN_NAME\"|g" .devcontainer/redmine.code-workspace
    rm .devcontainer/redmine.code-workspace.bak
fi

if [ ! -f .devcontainer/.env ] || ! grep -q "^PLUGIN_NAME=" .devcontainer/.env; then
    echo "PLUGIN_NAME=$PLUGIN_NAME" >> .devcontainer/.env
    echo "##### Rebuild the container to apply the changes. #####"
    exit 0
fi

cp Gemfile_for_test Gemfile

cd $REDMINE_ROOT

if [ -d .git.sv ]
then
    mv .git.sv .git
    git pull
    mv .git .git.sv
fi

if [ ! -f "$BASEDIR/init.rb" ]; then
    bash "$BASEDIR/.devcontainer/plugin_generator.sh"
fi

bundle install 

initdb() {
    rm -f db/schema.rb
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake redmine:plugins:migrate

    bundle exec rake db:drop RAILS_ENV=test
    bundle exec rake db:create RAILS_ENV=test
    bundle exec rake db:migrate RAILS_ENV=test
    bundle exec rake redmine:plugins:migrate RAILS_ENV=test
}

initdb

export DB=mysql2
export DB_NAME=redmine
export DB_USERNAME=root
export DB_PASSWORD=root
export DB_HOST=mysql
export DB_PORT=3306

initdb

export DB=postgresql
export DB_NAME=redmine
export DB_USERNAME=postgres
export DB_PASSWORD=postgres
export DB_HOST=postgres
export DB_PORT=5432

initdb