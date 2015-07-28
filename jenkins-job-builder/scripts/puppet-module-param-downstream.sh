set +x
###
### TODO: Need to be rewritten
###
# Setup Parameters for next job
#grab the module URL needed for updating the super-repo:
echo 'Saving parameters for new job'
cd $WORKSPACE
moduleURL=$(cat .git/config |grep url)
moduleURL=$(echo $moduleURL |sed 's/url = //g')
echo "moduleURL=$moduleURL" > parameters.txt
#branchName=$(git branch |grep \* |sed 's/\* //')
branchName='master'
if [[ "${JOB_NAME}" == PuppetDev* ]]; then
  branchName=$(echo ${JOB_NAME} |sed 's/.*-//')
fi

echo "branchName=$branchName" >> parameters.txt
#echo "DEBUG: done building downstream parameters"
set +x

