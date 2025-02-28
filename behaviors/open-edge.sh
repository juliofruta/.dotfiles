#!/bin/sh
url="$(git config --get remote.origin.url)"
open -a edge $url
