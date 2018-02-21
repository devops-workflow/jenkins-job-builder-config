set +x
# Unit test - Python
# Tools
# - pytest, pytest-cov
# - coverage.py

# Standard should be
#  <app>/tests
#  <app>/<submodule>/tests
#  ...
# find . -type d -name tests
# no tests & exit if nothing is returned
#
# Need to standardize the test dir name
if [ -d test ]; then
  testdir='test'
elif [ -d tests ]; then
  testdir='tests'
else
  echo "No unit tests available to run"
  exit
fi

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

pyenv activate "${JOB_NAME}"

###
### Start Testing stuff
###
echo -e "\nRunning unit tests"

if [ -f requirements.txt ]; then
  pip install -r requirements.txt
fi
if [ -f requirements-dev.txt ]; then
  pip install -r requirements-dev.txt
fi
pip install -U pytest pytest-cov
# May need to set PYTHONPATH
#appdir=$WORKSPACE/
#export PYTHONPATH=$appdir:$PYTHONPATH
if [ -f setup.py ]; then
  echo -e "\n\tValidating setup.py..."
  python setup.py check -s
  echo -e "\n\tInstalling app..."
  python setup.py install
  #echo -e "\n\tRunning unit tests..."
  #python setup.py test
  #echo -e "\n\tPackaging..."
  #python setup.py bdist_wheel
fi

#cd ${testdir}
py.test --junitxml=tests_junit.xml --cov ./ --cov-report term-missing --cov-report xml

#coverage run <program> <arg1 ...>
#coverage xml -o coverage.xml
