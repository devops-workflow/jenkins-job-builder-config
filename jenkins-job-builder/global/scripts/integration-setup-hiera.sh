set +x
#
# Setup for hiera data integration
#
# Make sure dir exists
# projects/<project>/
#env | sort

# Checkout dest branch if it exists, otherwise create it from master branch
git checkout production
git branch -a
if [ $(git branch -a | grep $branchDest | wc -l) -eq 0 ]; then
  # Use add-env script to get clean consistent branches
  ./add-env.sh $branchDest
fi
git checkout $branchDest

if [ -d hieradata/projects/${project} ]; then
  echo "Building existing var list"
  # Get all variables from all yaml files - hieradata/${project}/**/${repoSrc}.yaml - case insensitive
  grep -Rh : hieradata/projects/${project} | grep -v '#' | sed 's/:[^:]*$//;s/^ *//;s/ *$//' | sort | uniq > variableOrig.list
else
  mkdir -p hieradata/projects/${project}
  touch variableOrig.list
fi
mkdir -p tmp

