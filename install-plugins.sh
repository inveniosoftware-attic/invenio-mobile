#!/bin/sh
set -e

# Cordova's experimental plugin saving feature doesn't work with plugins that
# aren't in the registry yet, so this shell script is required as well.

cordova restore plugins --experimental

cordova plugins add https://github.com/pwlin/cordova-plugin-file-opener2.git
