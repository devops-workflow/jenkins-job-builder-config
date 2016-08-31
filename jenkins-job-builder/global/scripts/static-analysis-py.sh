set +x
# Static Analysis Checks - Python
# Tools - Coverage
# - coverage.py
# Tools - Security:
# - rats https://code.google.com/p/rough-auditing-tool-for-security/
# - Bandit https://wiki.openstack.org/wiki/Security/Projects/Bandit
# Tools - Style
# - pep8
# - PyLint
# - pychecker
# - pyflakes
# - flake8 http://flake8.readthedocs.org/en/latest/
# - hacking https://pypi.python.org/pypi/hacking
# Style Guide: https://www.python.org/dev/peps/pep-0008/

dir_reports='reports-analysis'

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
### Start Testing stuff
##
echo -e "\n\nFlake8 version"
flake8 --version

# Config tools
if [ ! -f .flake8 ]; then
  cat <<FLAKE8 >.flake8
[flake8]
exclude = test/*
FLAKE8
fi

if [ ! -f tox.ini ]; then
  cat <<TOX >tox.ini
[tox]
skipsdist = true
TOX
fi

mkdir -p $dir_reports

echo -e "\n\nxxxxxxxxxxxxxxxxx\nExecuting the Python Static Analysis testing:"
echo -e "TEST: flake8"
flake8 --version
flake8 . --exit-zero > ${dir_reports}/flake8.txt
if [ -f ${dir_reports}/flake8_junit.xml ]; then
  rm -f ${dir_reports}/flake8_junit.xml
fi
#flake8_junit ${dir_reports}/flake8.txt ${dir_reports}/flake8_junit.xml
pepper8 -o ${dir_reports}/flake8.html ${dir_reports}/flake8.txt

echo -e "\n\nxxxxxxxxxxxxxxxxx\nExecuting the Python Security testing:"
echo -e "TEST: bandit"
bandit --version
rm -f ${dir_reports}/bandit*
bandit -x .tox,test -r . || true
bandit -x .tox,test -r -f xml -o ${dir_reports}/bandit_junit.xml . || true
bandit -x .tox,test -r -f txt -o ${dir_reports}/bandit.txt . || true
bandit -x .tox,test -r -f html -o ${dir_reports}/bandit.html . || true

#echo -e "\n\nTEST: tox"
#tox

