set +x
# Syntax check - ERB
# erb -P -x -T - <template.erb> | ruby -c
# TODO:
# - create output that can be parsed by Jenkins warnings plugin

echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the ERB Syntax check:'
if [ -f /opt/puppetlabs/puppet/bin/ruby ]; then
  # Puppet >= 4.x
  ERB='/opt/puppetlabs/puppet/bin/erb'
  RUBY='/opt/puppetlabs/puppet/bin/ruby'
elif [ -f /opt/puppet/bin/ruby ]; then
  # Puppet Enterprise < 4.x
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
