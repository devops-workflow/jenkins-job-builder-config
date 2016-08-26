#!/bin/bash
#
# Setup everything for building a docker image
# Create the command line with variable assignments for all the ARG and TAG fields found in the Dockerfile
#

echo "Creating docker build arguments..."

dockerDir=.
dockerFile=${dockerDir}/Dockerfile

tmpdir=${WORKSPACE}/tmp
buildName=${tmpdir}/buildName
dockerBuildArgs=${tmpdir}/dockerBuildArgs
dockerImageId=${tmpdir}/dockerImageId
dockerTags=${tmpdir}/dockerTags
dockerTagsOnly=${tmpdir}/dockerTagsOnly
versionFile=${tmpdir}/version
imageDir=output-images

mkdir -p ${tmpdir}

# Setup variables
BUILD_DATE=$(date --utc +%Y-%m-%dT%H:%M:%S.%NZ)
GIT_URL="${GIT_URL%.git}"
# VERSION - need to be read in from a file and/or git
# Commit: git rev-parse --short HEAD
# USE THIS? Latest tag in current branch with info past tag: git describe --tags
# Can this be made to add difference of current commit to the tag?
# Latest tag across all branchs: git describe --tags $(git rev-list --tags --max-count=1)
if [ -n "$(git tag)" ]; then
  VERSION=$(git describe --tags)
else
  VERSION="0.0-$(git rev-list HEAD --count)-$(git rev-parse --short HEAD)"
fi
echo "${VERSION}" > ${versionFile}
#repository=$(grep org.label-schema.name= ${dockerFile} | sed 's/.*="//;s/".*//')
#if [ -z "${repository}" ]; then
  # Create repository name if not in Dockerfile
  gitRepo="${GIT_URL##*/}"
  gitOrg="${GIT_URL##*.com/}"
  gitOrg="${gitOrg%%/*}"
  repository="${gitOrg}/${gitRepo}"
  #echo "ERROR: No image name found in Dockerfile. Using: ${repository}"
#fi
REPOSITORY=${repository}

# Clean host of old image files in job
if [ -d ${imageDir} ]; then
 rm -rf ${imageDir}/*
fi
# Clean host of old images in Docker
echo "Removing images for: ${repository}..."
for I in $(docker images --format "{{.ID}}" ${repository} | sort -u); do
  docker rmi -f $I
done
# TODO: Improve and remove all untagged images.
# DANGEROUS: This will only work if ONLY 1 container job exists. Otherwise could be removing layers of other images.
# Needed due to lack of disk space. But better cleanup is needed
echo "Removing untagged images..."
for I in $(docker images -a --format "{{.ID}} {{.Tag}}" | grep '<none>' | cut -d\  -f1 | sort -u); do
  docker rmi -f $I
done

# Build command line for ARG variable assignments
cmdArgs=''
for A in $(grep ^ARG ${dockerFile} | cut -d\  -f2 | cut -d= -f1); do
  cmdArgs="${cmdArgs} --build-arg ${A}=${!A}"
done
echo "DEBUG: Args=${cmdArgs}"
echo "${cmdArgs}" > ${dockerBuildArgs}

# Build command line for addition tags from Dockerfile
cmdTags=''
buildTags=''
#buildTagsOnly=''
#for T in $(grep -E '[ #]TAG=' ${dockerFile} | sed 's/^.*TAG=//'); do
#  buildTags="${buildTags} ${T}"
#  buildTagsOnly="${buildTagsOnly} ${T}"
#  cmdTags="${cmdTags} -t ${T}"
#done
# Add standard build tags
# remove latest if use plugin
buildTags="${repository}:${VERSION} ${repository}:${BUILD_NUMBER} ${repository}:latest ${buildTags}"
#buildTagsOnly="${VERSION} ${BUILD_NUMBER} ${buildTagsOnly}"
cmdTags="-t ${repository}:${VERSION} -t ${repository}:${BUILD_NUMBER} -t ${repository}:latest ${cmdTags}"
echo "DEBUG: Tags=${cmdTags}"
echo "#${BUILD_NUMBER} ${buildTags}" > ${buildName}
#echo "${buildTags}" > ${dockerTags}
#echo "${buildTagsOnly}" > ${dockerTagsOnly}
echo "${cmdTags}" >> ${dockerBuildArgs}

echo "Finished creating docker build arguments."
