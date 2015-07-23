set +x
# Syntax check - Puppet
# puppet parser validate <file.pp>
echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Puppet Syntax check:'
if [ -f /opt/puppet/bin/puppet ]; then
  # Puppet Enterprise
  PUPPET='/opt/puppet/bin/puppet'
else
  PUPPET='puppet'
fi
echo -n 'Puppet version: '; $PUPPET --version
find . -name '*.pp' -type f | xargs -r -n 1 -t $PUPPET parser validate

# Another method
#for file in $(find . -iname '*.pp'); do
#  puppet parser validate --color false --render-as s --modulepath=modules $file || exit 1;
#done;
#
# Check OpenStack uses:
# find . -iname *.pp | xargs puppet parser validate --modulepath=`pwd`/modules
