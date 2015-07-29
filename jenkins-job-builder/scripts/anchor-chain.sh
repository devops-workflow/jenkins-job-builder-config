set +x
echo 'Creating/Updating AnchorChain file'
# Create or modify anchor chain file to create links for a job to its related resources
file_anchorchain=anchor
#dir_icons=userContent/customIcon
#dir_icons=customIcon
dir_icons=/userContent/customIcon

# Anchor Chain file format:
# name, url, icon
# Site wide icons will be in userContent/customIcon
#echo -e &quot;Wiki-SysAdmin\thttps://wiki.com/display/SystemAdmin/Home\thttps://wiki.com/s/1725/1/_/images/logo/confluence_16.png&quot; > links

#if [ ! -f $file_anchorchain ]; then
  # Create new file
  # TODO: change to HERE doc
  #cat <<ANCHOR > $file_anchorchain
# Ticketing Project
# Jira
echo -e "Project-Jira\thttp://url.com\t${dir_icons}/jira-logo.png" > $file_anchorchain
# Documentation
# Confluence
echo -e "Project-Confluence\thttp://url.com\t${dir_icons}/confluence-logo.png" >> $file_anchorchain

# Notification channel / chat
# Hipchat
echo -e "Project-Hipchat\thttp://url.com\t${dir_icons}/hipchat-logo.png" >> $file_anchorchain

# Monitoring

# Metrics
echo -e "Project-Grafana\thttp://url.com\t${dir_icons}/grafana-logo.png" >> $file_anchorchain
#else
  # Update existing file
  
# Get Icons: graphite, nagios, elastic search/kibana, 
