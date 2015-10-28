set +x
# Syntax check - Puppet
# puppet parser validate <file.pp>
echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Puppet Syntax check:'
if [ -f /opt/puppet/bin/puppet ]; then
  # Puppet Enterprise
  PUPPET_BIN='/opt/puppet/bin/puppet'
else
  PUPPET_BIN='puppet'
fi
PUPPET_OPTS='--storeconfigs'

echo -n 'Puppet version: '; $PUPPET_BIN --version
#find . -name '*.pp' -type f | xargs -r -n 1 -t $PUPPET_BIN parser validate

# Syntax check and setup output for parsing by Jenkins warnings plugin
for file in $(find . -iname '*.pp'); do
  $PUPPET_BIN parser validate $PUPPET_OPTS --color false --render-as s $file 2>&1 | \
    while read line; do
      echo "PUPPET_SYNTAX:$file:$line";
    done;
done

# Another method
#for file in $(find . -iname '*.pp'); do
#  puppet parser validate --color false --render-as s --modulepath=modules $file || exit 1;
#done;
#
# Check OpenStack uses:
# find . -iname *.pp | xargs puppet parser validate --modulepath=`pwd`/modules
