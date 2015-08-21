set +x
# Syntax check - EPP
# puppet epp validate <file | module/template>
# TODO:
# - create output that can be parsed by Jenkins warnings plugin

echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the EPP Syntax check:'
if [ -f /opt/puppet/bin/puppet ]; then
  # Puppet Enterprise
  PUPPET='/opt/puppet/bin/puppet'
else
  PUPPET='puppet'
fi

# puppet epp validate <file | module/template>
# Can render the template and then do testing on the results
# puppet epp render <template>
# puppet epp render <template> --values '{x => 10, y => 20}'

# Validate EPP templates
# Unit test templates ? or part of module's unit tests elsewhere
#    Both?
#	Render and syntax check results (sh, yaml, ...)
#	More specific as part of module's unit testing
