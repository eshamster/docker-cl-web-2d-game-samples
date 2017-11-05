#!/bin/sh

set -euC

if [ -z ${TARGET:-} ]; then
  echo "ERROR: The environment variable \"TARGET\" is not defined" 1>&2
  exit 1
fi

cd /root/.roswell/local-projects/work
git submodule foreach "git checkout master ; git pull --rebase"

cd cl-web-2d-game/sample

if [ ! -f ${TARGET}.ros ]; then
  echo "ERROR: The TARGET \"${TARGET}\" is not exist" 1>&2
  echo "HINT: There are the following targets: " 1>&2
  ls *.ros | sed -e 's/\.ros$//' 1>&2
  exit 1
fi

./${TARGET}.ros
