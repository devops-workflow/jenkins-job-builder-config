#!/bin/bash
#
# Build RPM
#
# Look at:
#  https://github.com/jhrcz/jenkins-rpm-builder
#
# Use Jenkins job build number in release version
#   should be in app and file name
#
set +x
pkg_rpm=$1

# Verify running under Jenkins or exit
if [ -z "$WORKSPACE" ]; then
  echo 'ERROR: Not running under Jenkins'
  exit 1
fi
# Clean RPM env
[ ! -d $WORKSPACE/rpm ] || rm -rf $WORKSPACE/rpm
# Setup RPM builder
mkdir -p $WORKSPACE/rpm/{BUILD,RPMS/{noarch,$(uname -p)},SOURCES,SPECS,SRPMS}
cat <<RPMMACROS > ~/.rpmmacros
%_topdir $WORKSPACE/
RPMMACROS

if [ -f build.sh ]; then
  ./build.sh
else
  # copy spec file to SPECS
  # copy source to SOURCES
  rpmbuild --define '_topdir '$WORKSPACE/rpm -ba SPECS/$pkg_rpm.spec
  # --define 'BUILD_NUMBER '$BUILD_NUMBER
  # Change release line to: Release : %{?BUILD_NUMBER}
fi

