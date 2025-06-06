#!/bin/bash

#set -x
#set -v

GetReleases()
 {
  list=$(gh release list -R "$1" --json tagName | jq -r 'map(select(true))[] | (.tagName)' | sed s/version_//g)
  tmpfile=mktemp
  touch $tmpfile
  for i in $list; do
    if [[ $i != *-* ]] && dpkg --compare-versions $i "ge" "2.9"; then 
      echo $i >>$tmpfile
    fi
  done
  sort <$tmpfile >$2
  rm -f $tmpfile
 }

THIS_REPO=$GITHUB_REPOSITORY
PRUSA_REPO=prusa3d/PrusaSlicer

cd "$GITHUB_WORKSPACE"
GetReleases "$PRUSA_REPO" "./Prusa.Releases"
GetReleases "$THIS_REPO" "./This.Releases"
VERSION=$(head -1 <<< "$(comm -23 Prusa.Releases This.Releases)")
rm -f "./Prusa.Releases" "./This.Releases"

if [ -z "${VERSION}" ]; then
  echo "No new release found. Skipping rest of workflow."
  echo "skip=true" >> "$GITHUB_OUTPUT"
 else
  echo "VERSION=${VERSION}" >> $GITHUB_ENV
  echo "VERSION=version_${VERSION}" >> "$GITHUB_OUTPUT"
  echo "New release found: ${VERSION}"
  echo "skip=false" >> "$GITHUB_OUTPUT"
fi

