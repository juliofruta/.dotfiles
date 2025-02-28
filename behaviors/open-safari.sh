#!/bin/sh
url="$(git remote get-url origin | sed -E 's/git@github\.com:(.*)/https:\/\/github.com\/\1/')"
open -a safari $url
