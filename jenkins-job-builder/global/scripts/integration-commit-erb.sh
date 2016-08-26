set +x
#
# Commit erb template changes to git
#
# build new var list from changes (diff) and untracked files (status)
# compare with original list

echo "== Moving templates =="
cp -Rvf tmp/config/* templates/${repoSrc}
rm -rf tmp/config

echo "== Creating new variable list =="
grep -Rh '<%=' templates/${repoSrc} | sed 's/.*<%= *//;s/ *-*%>.*//;s/^@//' | sort | uniq > variableNew.list
echo "CMD: diff variableOrig.list variableNew.list"
diff variableOrig.list variableNew.list | tee variables.diff
# rm if empty. So, notification is not triggered
if [ ! -s variables.diff ]; then
  rm -f variables.diff
fi

git add templates/${repoSrc}/*
git commit -m "Integrating templates for ${project} from ${repoSrc}" || true

# Error and build fail if they are different
#	email (include diff list) and jira ticket
# Get git-changelog to work and sent changelog

