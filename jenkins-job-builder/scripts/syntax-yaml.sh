set +x
echo "Syntax check: YAML"
# ruby -e 'require "yaml";YAML.load($stdin.read)' < FILE
echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the YAML Syntax check:'
find . -name '*.yaml' -type f | xargs -r -n 1 -I XxX -t /opt/puppet/bin/ruby -e 'require "yaml";YAML.load_file("XxX")'
