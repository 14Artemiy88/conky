#!/bin/bash

COVER="/tmp/album_cover.png"
COVER_SIZE="40"
DEFAULT_COVER="/home/artemiy/.conky/scripts/img/nocover.png"

file="$(mpc --format %file% current | python3 -c 'import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()));')"
album="${file%/*}"
#search for cover image
art=$(find "${album#file://}" -maxdepth 2 -iregex ".*/.*\(cover\|folder\|artwork\|front\).*[.]\(jpe?g\|png\|gif\|bmp\)")
if [ "$art" = "" ]; then
  art=$(find "${album#file://}"  -maxdepth 1 | grep -m 1 ".*\.\(jpg\|png\|gif\|bmp\)")
fi
if [ "$art" = "" ]; then
  art=$DEFAULT_COVER
fi

#copy and resize image to destination
ffmpeg -loglevel 0 -y -i "$art" -vf "scale=$COVER_SIZE:-1" "$COVER"
