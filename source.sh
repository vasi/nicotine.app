#!/bin/sh -ev
mkdir -p src
pushd src

while read url; do
  if [ -n "$url" ]; then
    base=`basename $url`
    if [ \! -f $base ]; then
      echo $url
      curl -O -L "$url"
    fi
  fi
done < $BASEDIR/source.txt

popd
