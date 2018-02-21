set +x
#
# Setup downstream job parameters
#
# Used for all integration jobs
#env | sort
fileProps=parameters.properties
echo 'Building downstream parameters...'

if [ -z "$rootJob" ]; then
  # Keep upstream value
  rootJob=$JOB_NAME
fi
# May not need. build-user-vars plugin appears to provide root trigger user, not job trigger user
# Need to verify this more
#if [ -z "$rootUser" ]; then
#  #[ "$BUILD_CAUSE" == "$ROOT_BUILD_CAUSE" ]; then
#  # if MANUALTRIGGER -> a user?, url, others?, else something else
#  rootUser=$BUILD_USER
#fi
#echo "Workflow was initiated by $rootUser with job $rootJob"
echo "Project: ${project}"
# Get project, git org and repo
#   parse $JOB_NAME
#     <project>-<repo>_<function>_<function type>_<branch>
if [ -z "$project" ]; then
  # Keep upstream value
  project=${JOB_NAME%%-*}
fi
echo "Project: ${project}"
# Get org and repo from $GIT_URL
# GIT_URL=https://github.com/devops-workflow/TestingJenkins.git
repoSrc=${GIT_URL##*/}
repoSrc=${repoSrc%%.*}
repoSrcOrg=${GIT_URL%/*}
repoSrcOrg=${repoSrcOrg##*/}
echo "RepoSrcOrg: ${repoSrcOrg}"
echo "RepoSrc: ${repoSrc}"

### For ERB
projectLC=$(echo $project | tr '[:upper:]' '[:lower:]')
repoDestSite="fe_${projectLC}_site"
echo "RepoDestSite: ${repoDestSite}"

# Source branch
# GIT_BRANCH=origin/master
branchSrc=${GIT_BRANCH##*/}
echo "BranchSrc: ${branchSrc}"

# Dest branch in site
case "$branchSrc" in
  master)
    branchDest='dev'
    ;;
  dev|development|qa|stage|perf|production)
    echo "ERROR: Reserved branch name: ${branchSrc}"
    exit 1
    ;;
  *)
    branchDest=$branchSrc
    ;;
esac

#rootUser=$rootUser
# Create parameters file
cat <<PROPS >$fileProps
project=$project
repoSrc=$repoSrc
repoSrcOrg=$repoSrcOrg
repoDestSite=$repoDestSite
branchSrc=$branchSrc
branchDest=$branchDest
rootJob=$rootJob
upstreamJob=$JOB_NAME
PROPS
