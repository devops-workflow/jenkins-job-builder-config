#!/bin/bash
set +x
# Setup Python and virtual environment
# Using PyEnv and Virtualenv
#
# Design as Jenkins job to call first before actual build steps to make sure everything it setup

# Requirements:
#  git, curl
#
# Parameters:
#   python_ver  python version
#   venv        virtual environment name - Should name space with job name
#     Look if can put in $WORKSPACE
#

## Install PyEnv
# Assume master ${JENKINS_HOME} - make work on slave also
if [ -d "${JENKINS_HOME}" ]; then
  # or [ "${NODE_NAME}" = "master" ]
  home=${JENKINS_HOME}
else
  home=${HOME}
fi
export PYENV_ROOT="${home}/.pyenv"
export PATH="${PYENV_ROOT}/bin:${PATH}"
if [ ! -d "${PYENV_ROOT}" ]; then
  echo "Installing PyEnv..."
  curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
fi

## Install PyEnv VirtualEnv
if [ ! -d "$PYENV_ROOT/plugins/pyenv-virtualenv" ]; then
  echo "Installing pyenv-virtualenv ..."
  git clone https://github.com/yyuu/pyenv-virtualenv.git $PYENV_ROOT/plugins/pyenv-virtualenv
fi

# FAIL is PyEnv didn't get installed
if [ ! -d "${PYENV_ROOT}" ]; then
  exit 1
fi

## Update PyEnv
pyenv update
pushd $PYENV_ROOT/plugins/pyenv-virtualenv
git pull
popd

## Initialize PyEnv and virtualenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

## Install Python version. If needed
if [ $(pyenv versions | grep ${python_ver} | wc -l) = 0 ]; then
  pyenv install ${python_ver}
  if [ $(pyenv versions | grep ${python_ver} | wc -l) = 0 ]; then
    echo "ERROR: failed to install Python ${python_ver}"
    exit 1
  fi
fi

## Create Virtual Environment. If needed
# Look at creating in local workspace
if [ $(pyenv virtualenvs | grep ${venv} | wc -l) = 0 ]; then
  pyenv virtualenv "${python_ver}" "${venv}"
  if [ $(pyenv virtualenvs | grep ${venv} | wc -l) = 0 ]; then
    echo "ERROR: failed to create virtual environment ${python_ver} ${venv}"
    exit 1
  fi
fi

pyenv activate "${venv}"
pip install --upgrade pip

## Validate
echo "PyEnv Versions"
pyenv versions
echo "Current Versions:"
pyenv version
python --version
pip --version
echo "Virtual Envs:"
pyenv virtualenvs

