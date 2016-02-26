#!/bin/bash
#
# Update Icons in Jenkins from Git repo
#
# Rename and copy
#   $WORKSPACE/files/jenkins/images/*.png $JENKINS_HOME/userContent/customIcon

src="${WORKSPACE}/files/jenkins/images"
dst="${JENKINS_HOME}/userContent/customIcon"

for Icon in $(ls -1 ${src}/*.png); do
  filename=$(basename $Icon)
  echo "Processing image: $filename"
  if [[ $filename =~ ^(.+)-logo ]]; then
    name=${BASH_REMATCH[1]}
    #echo "MATCH: logo: ${name}"
  elif [[ $filename =~ ^(.+)-[0-9]+ ]]; then
    name=${BASH_REMATCH[1]}
    #echo "MATCH: -[0-9]+: ${name}"
  else
    echo "WARNING: Unknown image name: ${filename}"
    continue
  fi
  echo "copy ${filename} ${name}.png"
  cp ${src}/${filename} ${dst}/${name}.png
done
