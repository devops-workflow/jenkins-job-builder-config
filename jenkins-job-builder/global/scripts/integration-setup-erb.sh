set +x
#
# Setup for erb template integration
#
# Assumes files are going to a site repo dedicated to the project

# Make sure dir exists
# <project>/<repo|module>/
# Build var list from above dir
#env | sort

# Checkout dest branch if it exists, otherwise create it from master branch
git checkout master
git branch -a | tee branches.list
if [ $(grep $branchDest branches.list | wc -l) -eq 0 ]; then
  git branch $branchDest
fi
git checkout $branchDest

if [ -d templates/${repo} ]; then
  echo "Building existing var list..."
  grep -Rh '<%=' templates/${repoSrc} | sed 's/.*<%= *//;s/ *-*%>.*//;s/^@//' | sort | uniq > variableOrig.list
else
  mkdir -p templates/${repoSrc}
  touch variableOrig.list
fi
mkdir -p tmp

