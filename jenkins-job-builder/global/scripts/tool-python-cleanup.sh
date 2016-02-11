#!/bin/bash
set +x
# Cleanup Python and virtual environment
#

if [ -d "${JENKINS_HOME}" ]; then
  # or [ "${NODE_NAME}" = "master" ]
  home=${JENKINS_HOME}
else
  home=${HOME}
fi
export PYENV_ROOT="${home}/.pyenv"
if [ -d "${PYENV_ROOT}" ]; then
  rm -rf ${PYENV_ROOT}
fi
