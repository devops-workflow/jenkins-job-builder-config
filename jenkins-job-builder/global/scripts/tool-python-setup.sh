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
#   pkgs	python packages to ensure are installed
#   pkgs_ver	Should packages always be the latest (present|latest)
#   rebuild     Boolean - Rebuild virtual environment if true
#

if [ -f /usr/local/git/bin/git ]; then
  export PATH=/usr/local/git/bin:${PATH}
fi

## Install PyEnv
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
if [ $(pyenv versions --skip-aliases --bare | grep ${python_ver} | wc -l) = 0 ]; then
  pyenv install ${python_ver}
  if [ $(pyenv versions --skip-aliases --bare | grep ${python_ver} | wc -l) = 0 ]; then
    echo "ERROR: failed to install Python ${python_ver}"
    exit 1
  fi
fi

## Create Virtual Environment. If needed
# TODO:
#   Look at creating in local workspace
found=''
envs=$(pyenv virtualenvs --skip-aliases --bare)
for E in ${envs}; do
  if [ "${venv}" == "${E##*/}" ]; then
    found=1
    if [ $rebuild == "true" -o "${python_ver}" != ${E%%/*} ]; then
      echo "Rebuilding virtual environment for: ${python_ver} ${venv}"
      pyenv virtualenv-delete -f "${venv}"
      pyenv virtualenv "${python_ver}" "${venv}"
    fi
  fi
done
if [ "${found}" != "1" ]; then
  echo "Creating new virtual environment for: ${python_ver} ${venv}"
  pyenv virtualenv "${python_ver}" "${venv}"
fi

if [ $(pyenv virtualenvs | grep ${venv} | wc -l) = 0 ]; then
  pyenv virtualenv "${python_ver}" "${venv}"
  if [ $(pyenv virtualenvs | grep ${venv} | wc -l) = 0 ]; then
    echo "ERROR: failed to create virtual environment ${python_ver} ${venv}"
    exit 1
  fi
fi

pyenv activate "${venv}"
#pip install --upgrade pip

###
### Install and upgrade packages
###
# Ensure all requested packages are installed
declare -A pkgs_installed pkgs_to_install
for pkg in $(pip freeze); do
  pkg_name=${pkg%%=*}
  pkgs_installed[${pkg_name}]=1
done
# Build list of missing packages to install
for pkg in ${pkgs}; do
  if [ ! ${pkgs_installed[${pkg}]} ]; then
    pkgs_to_install[${pkg}]=1
  fi
done
if [ $(echo "${!pkgs_to_install[@]}" | wc -c) -gt 1 ]; then
  pip install "${!pkgs_to_install[@]}"
fi

# If latest, update all outdated packages
# This can causes some packages to be too new and cause others to fails
# TODO: figure out better way
if [ ${pkgs_ver} = 'latest' ]; then
  pkgs_to_upgrade=$(pip list --outdated | awk '{ print $1 }')
  if [ -n "${pkgs_to_upgrade}" ]; then
    pip install --upgrade ${pkgs_to_upgrade}
  fi
fi

###
### Validate
###
echo "PyEnv Versions"
pyenv versions
echo "Current Versions:"
echo -ne "pyenv version: " && pyenv version
python --version
pip --version
echo "Virtual Envs:"
pyenv virtualenvs
echo "Installed Python packages:"
#pip list
pip freeze

