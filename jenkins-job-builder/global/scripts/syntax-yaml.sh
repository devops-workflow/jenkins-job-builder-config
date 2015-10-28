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

# ruby -e 'require "yaml";YAML.load($stdin.read)' < FILE
echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the YAML Syntax check:'
find . -name '*.yaml' -type f | xargs -r -n 1 -I XxX -t /opt/puppet/bin/ruby -e 'require "yaml";YAML.load_file("XxX")'
