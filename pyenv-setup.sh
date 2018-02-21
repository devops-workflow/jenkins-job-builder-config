if [ -d "${JENKINS_HOME}" ]; then
  # or [ "${NODE_NAME}" = "master" ]
  home=${JENKINS_HOME}
else
  home=${HOME}
fi
export PYENV_ROOT="${home}/.pyenv"
export PATH="${PYENV_ROOT}/bin:${PATH}"

## Initialize PyEnv and virtualenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

export PYTHONWARNINGS="ignore:Unverified HTTPS request"

pyenv activate testing
