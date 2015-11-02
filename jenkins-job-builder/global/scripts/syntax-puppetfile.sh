set +x
# Syntax check - Puppetfile
# r10k puppetfile check <file.pp>
echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Puppetfile Syntax check:'
# /usr/local/bin/r10k

find . -name Puppetfile -type f | xargs -r -n 1 -t r10k puppetfile check
