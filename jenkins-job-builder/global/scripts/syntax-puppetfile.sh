set +x
# Syntax check - Puppetfile
# r10k puppetfile check <file.pp>
echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Puppetfile Syntax check:'
if [ -f /opt/puppet/bin/r10k ]; then
  # Puppet Enterprise
  R10K_BIN='/opt/puppet/bin/r10k'
else
  R10K_BIN='r10k'
  # /usr/local/bin/r10k
fi

find . -name Puppetfile -type f | xargs -r -n 1 -t $R10K_BIN puppetfile check
