set +x
# Syntax check - Python
# python -m py_compile $file

echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Python Syntax check:'
###
### Setup virtual environment
###
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

pyenv activate "${venv}"

###
### Syntax check
###
find . -name '*.py' -type f | xargs -r -n 1 -t python -m py_compile
