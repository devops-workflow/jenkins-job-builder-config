set +x
# Syntax check - Bash
# bash -n <file.rb>
#
# Output is setup to be parsed by Jenkins warnings plugin

echo "Syntax check: Bash"

echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Bash Syntax check:'
for file in $(find . -name '*.sh' -type f); do
  bash -n $file 2>&1 | while read line; do
    echo "BASH_SYNTAX:$line";
  done
done

