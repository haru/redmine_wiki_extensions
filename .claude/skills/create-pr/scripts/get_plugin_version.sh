#!/usr/bin/env bash
# Print the version declared in a Redmine plugin's init.rb (e.g. "1.2.0").
# Usage: get_plugin_version.sh [path/to/init.rb]
set -euo pipefail

init_rb="${1:-init.rb}"

version=$(sed -n "s/^[[:space:]]*version[[:space:]]*['\"]\\([^'\"]*\\)['\"].*/\\1/p" "$init_rb" | head -1)

if [ -z "$version" ]; then
  echo "Could not find a 'version \"x.y.z\"' line in $init_rb" >&2
  exit 1
fi

echo "$version"
