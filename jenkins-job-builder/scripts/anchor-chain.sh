set +x
echo 'Creating/Updating AnchorChain file'
# Create or modify anchor chain file to create links for a job to its related resources
file_anchorchain=anchor
dir_icons=userContent/customIcon

# Anchor Chain file format:
# name, url, icon
# Site wide icons will be in userContent/customIcon

#if [ ! -f $file_anchorchain ]; then
  # Create new file
  # TODO: change to HERE doc
  #cat <<ANCHOR > $file_anchorchain
# Ticketing Project
# Jira
echo "Project-Jira,http://url,${dir_icons}/jira-logo.png" > $file_anchorchain
# Documentation
# Confluence
echo "Project-Confluence,http://url.com,${dir_icons}/confluence-logo.png" >> $file_anchorchain

# Notification channel / chat
# Hipchat
echo "Project-Hipchat,http://url.com,${dir_icons}/hipchat-logo.png" >> $file_anchorchain

# Monitoring

# Metrics
echo "Project-Grafana,http://url.com,${dir_icons}/grafana-logo.png" >> $file_anchorchain
#else
  # Update existing file
  
# Get Icons: graphite, nagios, elastic search/kibana, 
