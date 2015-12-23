set +x
#
# Documentation Generation - Puppet
#
# Parameters to Jenkins Job:
#	Puppet Environment/branch to generate
#
# Use r10k and control report to populate module tree for environment/branch
# Generate doc tree
# tar doc tree to prepare it to be copied to documention server
#
# Write Support for old and new inline documentation styles
#	PuppetDoc, 
#	Strings (built on YARN) https://github.com/puppetlabs/puppetlabs-strings
#
if [ -f /opt/puppet/bin/puppet ]; then
  # Puppet Enterprise
  PUPPET='/opt/puppet/bin/puppet'
else
  PUPPET=$(whereis -b puppet | cut -d: -f2 | cut -c2-)
fi

# Jenkins fix
unset GEM_PATH

echo 'Documentation Generation: Puppet for $env'

## NOT usable yet
### Old code to rework

# Puppet Doc
# puppet doc --outputdir /var/www/puppetdocs/ --mode rdoc
echo 'xxxxxxxxxxxxxxxxx';echo 'Building the Puppet Documention:'
#find . -name '*.pp' -type f | xargs -r -n 1 -t /opt/puppet/bin/puppetdoc --outputdir ./puppetdocs/ --mode rdoc
# Does not work/opt/puppet/bin/puppet doc --all --outputdir puppetdocs --modulepath modules --mode rdoc manifests/site.pp
#

# Fix modules so doc will run
rm -f modules/httpd/files/puppet-ca-bundle.pem modules/elasticsearch/spec/fixtures/modules/boilerplate
touch modules/httpd/files/puppet-ca-bundle.pem
touch modules/elasticsearch/spec/fixtures/modules/boilerplate
# jetty redefines def
rm -f modules/jetty/spec/fixtures/modules/jetty/manifests/init.pp
rm -f modules/limits/spec/fixtures/modules/limits/manifests/limits.pp


# Another doc generation
### Cleanup old docs.
[ -d puppetdoc/ ] && rm -rf puppetdoc/
### Dummy manifests folder.
#! [ -d manifests/ ] && mkdir manifests/
### Generate docs
${PUPPET} doc --mode rdoc --manifestdir manifests/ --modulepath ./modules/ --outputdir puppetdoc

### Fix docs to remove the complete workspace from all the file paths.
#if [ -d ${WORKSPACE}/doc/files/${WORKSPACE}/modules ]; then
#  mv -v "${WORKSPACE}/doc/files/${WORKSPACE}/modules" "${WORKSPACE}/doc/files/modules"
#fi;
#grep -l -R ${WORKSPACE} * | while read fname; do sed -i 's@${WORKSPACE}/@/@g' $fname; done;

# Publish HTML Reports
#   doc, index.html, Puppet Docs
