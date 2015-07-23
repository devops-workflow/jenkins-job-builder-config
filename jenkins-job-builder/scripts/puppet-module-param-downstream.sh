set -x
# Setup Parameters for next job
#grab the module URL needed for updating the super-repo:
echo 'Saving parameters for new job'
cd $WORKSPACE
moduleURL=`cat .git/config |grep url`
moduleURL=`echo $moduleURL |sed s/&quot;url = &quot;//g`
echo "moduleURL=$moduleURL" > parameters.txt
#branchName=`git branch |grep \* |sed s/&quot;\* &quot;//`
branchName='master'
if [[ "${JOB_NAME}" == PuppetDev* ]]; then
  branchName=`echo ${JOB_NAME} |sed s/&quot;.*-&quot;//`
fi

echo "branchName=$branchName" >> parameters.txt
set +x

