set +x
# Syntax check - Ruby
# ruby -c <file.rb>
echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Ruby Syntax check:'
if [ -f /opt/puppet/bin/ruby ]; then
  # Puppet Enterprise
  RUBY='/opt/puppet/bin/ruby'
else
  RUBY='ruby'
fi
find . -name '*.rb' -type f ! -wholename '*_spec.rb' | xargs -r -n 1 -t $RUBY -c

