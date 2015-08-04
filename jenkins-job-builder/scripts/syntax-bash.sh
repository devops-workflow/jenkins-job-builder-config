set +x
# Syntax check - Bash
# bash -n <file.rb>
# TODO:
# - create output that can be parsed by Jenkins warnings plugin

echo "Syntax check: Bash"

echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Bash Syntax check:'
find . -name '*.sh' -type f | xargs -r -n 1 bash -n
