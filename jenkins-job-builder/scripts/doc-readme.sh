set +x
# Test for README files
#
# Stash only supports README.{md,txt} and README confuses it so must be absent
echo 'xxxxxxxxxxxxxxxxx';echo 'TESTING: readme files'
if [ -f README ]; then
  echo 'ERROR: Stash does not support README without an extension. Must be .md or .txt'
  exit 1
fi
if [ ! -f 'README.md' ] && [ ! -f 'README.markdown' ] && [ ! -f 'README.txt' ]; then
  echo 'ERROR: No README.md or README.txt file'
  exit 1
fi
# There are also: README.rdoc and README.markdown from GitHub repos. Should allow them.
echo 'README OK'

