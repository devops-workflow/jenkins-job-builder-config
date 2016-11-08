
#
# Create property file with environment variables that can be injected into Jenkins job
#
# TODO: validate that 1 of these succeeded, else fail - Not under Jenkins

dirTmp='tmp'
envVars="${dirTmp}/env.properties"

if [ -d "${JENKINS_HOME}" ]; then
  # or [ "${NODE_NAME}" = "master" ]
  # Jenkins master
  HOME=${JENKINS_HOME}
else
  # Jenkins build slave
  HOME=${WORKSPACE%%/workspace*}
fi
PATH=${PATH}:${HOME}/bin
mkdir -p ${dirTmp}
echo "HOME=${HOME}" > ${envVars}
echo "PATH=${PATH}" >> ${envVars}
