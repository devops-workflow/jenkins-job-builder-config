set +x
# Syntax check - ERB
# erb -P -x -T - <template.erb> | ruby -c
# TODO:
# - create output that can be parsed by Jenkins warnings plugin

echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the ERB Syntax check:'
if [ -f /opt/puppet/bin/ruby ]; then
  # Puppet Enterprise
  ERB='/opt/puppet/bin/erb'
  RUBY='/opt/puppet/bin/ruby'
else
  ERB='erb'
  RUBY='ruby'
fi
find . -name '*.erb' -type f | xargs -r -n 1 -t $ERB -P -x -T - | $RUBY -c

# Check OpenStack uses:
# for f in `find . -iname *.erb` ; do
#   erb -x -T '-' $f | ruby -c
# done
