#set +x
set -x
# Style Check - Puppet Lint
# puppet-lint --with-filename .
echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Puppet Lint testing:'
if [ -f /opt/puppet/bin/puppet-lint ]; then
  # Puppet Enterprise
  LINT='/opt/puppet/bin/puppet-lint'
else
  LINT='puppet-lint'
fi
echo "DEBUG: LINT=$LINT="
find . -name '*.pp' -type f | xargs -r -n 1 -t $LINT --log-format '%{path}:%{linenumber}:%{check}:%{KIND}:%{message}' --no-autoloader_layout-check --with-filename

# Another method
#find . -iname *.pp -exec puppet-lint --log-format '%{path}:%{linenumber}:%{check}:%{KIND}:%{message}' {} \;

# Check OpenStack uses:
# if [ -f Modulefile -o -f metadata.json ]; then
#   if [ -f Modulefile ]; then
#     MODULE=$(awk '/^name/ {print $NF}' Modulefile |tr -d \"\')
#   elif [ -f metadata.json ]; then
#     MODULE=$(python -c 'import json;print json.load(open("metadata.json"))["name"]')
#   fi
#   if [ -z "$MODULE" ]; then
#     echo "Module name not defined in Modulefile or metadata.json"
#   else
#     mkdir -p "$MODULE"
#     rsync -a --exclude="$MODULE" --exclude ".*" . "$MODULE"
#     cd "$MODULE"
#   fi
# fi
# if [ -f Gemfile ]; then
#   mkdir .bundled_gems
#   export GEM_HOME=`pwd`/.bundled_gems
#   bundle install --without system_tests
#   bundle exec rake lint 2>&1
# else
#   rake lint 2>&1
# fi

