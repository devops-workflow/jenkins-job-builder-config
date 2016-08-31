set +x
# Syntax check - YAML
# Currently using ruby yaml module
# TODO: 
# - Update to use library puppet is using for yaml parsing
# - create output that can be parsed by Jenkins warnings plugin
# Tools: (possible):
# - https://github.com/Pryz/yaml-lint
# - Kwalify - Could define schema for hiera then have Kwalify verify hiera file. But could be too much work to maintain
# -- there is a puppet module for kwalify. Could build scheme as part of a puppet module's test suite
# - travis-yaml - For validating .travis.yml

echo "Syntax check: YAML"
if [ -f /opt/puppetlabs/puppet/bin/ruby ]; then
  # Puppet >= 4.x
  RUBY='/opt/puppetlabs/puppet/bin/ruby'
elif [ -f /opt/puppet/bin/ruby ]; then
  # Puppet Enterprise < 4.x
  RUBY='/opt/puppet/bin/ruby'
else
  RUBY='ruby'
fi

# ruby -e 'require "yaml";YAML.load($stdin.read)' < FILE
echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the YAML Syntax check:'
find . \( -name '*.yaml' -o -name '*.yml' \) -type f | xargs -r -n 1 -I XxX -t $RUBY -e 'require "yaml";YAML.load_file("XxX")'
