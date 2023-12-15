#!/bin/sh

set -e

test() {
  if [ "$2" != "" ]; then
    echo "----------------------------------------"
  fi
  echo "$1"
  echo "----------------------------------------"
}

test "help"
./update-formula -h

test "version" 1
./update-formula -V

test "dry-run" 1
./update-formula -d src/yaml2json.rb

test "updating" 1
./update-formula src/yaml2json.rb
git checkout src/yaml2json.rb

echo "done"
