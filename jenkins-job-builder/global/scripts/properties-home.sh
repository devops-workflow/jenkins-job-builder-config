
#
# Create property file with environment variables that can be injected into Jenkins job
#
# TODO: validate that 1 of these succeeded, else fail - Not under Jenkins

dirTmp='tmp'
envVars="${dirTmp}/env.properties"

if [ -d "${JENKINS_HOME}" ]; then
  # or [ "${NODE_NAME}" = "master" ]
  # Jenkins master
  NODE_HOME=${JENKINS_HOME}
else
  # Jenkins build slave
  NODE_HOME=${WORKSPACE%%/workspace*}
fi
PATH=${PATH}:${NODE_HOME}/bin
mkdir -p ${dirTmp}
echo "NODE_HOME=${NODE_HOME}" > ${envVars}
echo "HOME=${WORKSPACE}" >> ${envVars}
echo "PATH=${PATH}" >> ${envVars}
