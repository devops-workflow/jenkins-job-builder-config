set +x
echo "Syntax check: Bash"
echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Bash Syntax check:'
find . -name '*.sh' -type f | xargs -r -n 1 bash -n
