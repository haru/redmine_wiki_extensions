#!/bin/sh
cd $(dirname "$0") || exit
GITPODDIR=$(pwd)
IGNOREDIR="$HOME"/.config/git
mkdir -p "$IGNOREDIR"
cp "$GITPODDIR"/ignore "$IGNOREDIR"
cd ..
BASEDIR=$(pwd)

if [ -f Gemfile_for_test ]; then
  cp Gemfile_for_test Gemfile
fi
cd ..
REDMINEDIR=$(pwd)/redmine
if [ ! -d redmine ]; then
    git clone https://github.com/redmine/redmine.git -b "$REDMINE_VERSION"
    cd redmine || exit
    mv .git .git.org
    cd "$REDMINEDIR"/plugins || exit
    ln -s "$BASEDIR" .
    cp "$GITPODDIR"/database.yml "$REDMINEDIR"/config/
    mkdir "$REDMINEDIR"/.vscode
    cd "$REDMINEDIR"/.vscode || exit
    ln -s "$GITPODDIR"/launch.json .
    echo "gem 'ruby-debug-ide'" >> "$REDMINEDIR"/Gemfile
    echo "gem 'debase'" >> "$REDMINEDIR"/Gemfile
    sed -i 's/^end$/  config.hosts.clear\nend/' "$REDMINEDIR"/config/environments/development.rb
fi


