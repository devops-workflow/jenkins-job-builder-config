
#
# Set HOME to the jenkins directory and add $HOME/bin to path
# Using HOME so all apps that use that stay in the Jenkins data directory, not the user's home
#

# TODO: validate that 1 of these succeeded, else fail - Not under Jenkins

if [ -d "${JENKINS_HOME}" ]; then
  # or [ "${NODE_NAME}" = "master" ]
  # Jenkins master
  HOME=${JENKINS_HOME}
else
  # Jenkins build slave
  HOME=${WORKSPACE%%/workspace*}
fi
PATH=${PATH}:${HOME}/bin
