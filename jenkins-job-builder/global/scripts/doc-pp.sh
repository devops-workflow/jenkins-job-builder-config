set +x
# Test Puppet Documentation and Metadata
# puppet doc --outputdir /var/www/puppetdocs/ --mode rdoc
# TODO:
#	Support for Puppet Doc and Strings
#	Test for RDoc coverage: http://github.com/petems/puppet-doc-lint
#	Metadata json validation: https://github.com/puppet-community/metadata-json-lint
#	Build so output (warnings/alerts/metrics) can be consumed in Jenkins
#
if [ -f /opt/puppet/bin/puppet ]; then
  # Puppet Enterprise
  PUPPET='/opt/puppet/bin/puppet'
  LINT='/opt/puppet/bin/metadata-json-lint'
else
  PUPPET=$(whereis -b puppet | cut -d: -f2 | cut -c2-)
  LINT=$(whereis -b metadata-json-lint | cut -d: -f2 | cut -c2-)
fi

# Jenkins fix
unset GEM_PATH

echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Puppet Doc testing:'
find . -name '*.pp' -type f | xargs -r -n 1 -t ${PUPPET} doc --outputdir ./puppetdocs/ --mode rdoc

if [ -f metadata.json ]; then
  echo 'xxxxxxxxxxxxxxxxx';echo 'Executing the Puppet Metadata testing:'
  ${LINT} metadata.json
fi

#set +x
# Another doc generation
### Cleanup old docs.
#[ -d doc/ ] && rm -rf doc/
### Dummy manifests folder.
#! [ -d manifests/ ] && mkdir manifests/
### Generate docs
#puppet doc --mode rdoc --manifestdir manifests/ --modulepath ./modules/ --outputdir doc
# 
### Fix docs to remove the complete workspace from all the file paths.
#if [ -d ${WORKSPACE}/doc/files/${WORKSPACE}/modules ]; then
#  mv -v "${WORKSPACE}/doc/files/${WORKSPACE}/modules" "${WORKSPACE}/doc/files/modules"
#fi;
#grep -l -R ${WORKSPACE} * | while read fname; do sed -i "s@${WORKSPACE}/@/@g" $fname; done;

# Publish HTML Reports
#   doc, index.html, Puppet Docs

