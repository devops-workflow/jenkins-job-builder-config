set +x
#
# Commit hiera data changes to git
#
# build new var list from changes (diff) and untracked files (status)
# compare with original list

echo "== Moving Hiera Data =="
pushd tmp/config/hiera
find . -type f -iname "${repoSrc}.yaml" | xargs -r -n 1 -I XxX cp -vf --parents XxX $WORKSPACE/hieradata/projects/${project}/
popd

echo "== Creating new variable list =="
#grep -Rh '<%=' templates/${project}/${repoSrc} | sed 's/.*<%= *//;s/ *-*%>.*//;s/^@//' | sort | uniq > variableNew.list
grep -Rh : hieradata/projects/${project} | grep -v '#' | sed 's/:[^:]*$//;s/^ *//;s/ *$//' | sort | uniq > variableNew.list
echo "CMD: diff variableOrig.list variableNew.list"
diff variableOrig.list variableNew.list | tee variables.diff
# rm if empty. So, notification is not triggered
if [ ! -s variables.diff ]; then
  rm -f variables.diff
fi

git add hieradata/projects/${project}/*
git commit -m "Integrating hiera data for ${project} from ${repoSrc}" || true

# Error and build fail if they are different
#	email (include diff list) and jira ticket
# Get git-changelog to work and sent changelog

