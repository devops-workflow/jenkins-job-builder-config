set +x
# Unit tests - Puppet
echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Puppet Unit testing:'
#if [ -f /opt/puppet/bin/puppet-lint ]; then
#  # Puppet Enterprise
#  LINT='/opt/puppet/bin/puppet-lint'
#else
#  LINT=$(whereis -b puppet-lint | cut -d: -f2 | cut -c2-)
#fi

# Jenkins fix
unset GEM_PATH

# Setup virtual environment for job and do this there
bundler install
bundler exec rake test

# How to bring results into Jenkins UI ?
# - Both tests and coverage results
# Plugin ? 
#   bootstraped-multi-test-results-report
#     Requires Jenkins master running on Java 8
