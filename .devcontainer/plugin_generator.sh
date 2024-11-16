#!/bin/bash
set -e

cd `dirname $0`
cd ..
BASEDIR=`pwd`
PLUGIN_NAME=`basename $BASEDIR`
echo $PLUGIN_NAME

cd $REDMINE_ROOT

export RAILS_ENV="production"

bundle exec rails generate redmine_plugin $PLUGIN_NAME