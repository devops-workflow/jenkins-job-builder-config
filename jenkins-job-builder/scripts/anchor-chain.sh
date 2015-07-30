set +x
echo 'Creating/Updating AnchorChain file'
# Create or modify anchor chain file to create links for a job to its related resources
#
# Ideas of things to link:
#-----------------
# Ticketing Project: Jira
# Documentation: Confluence
# Notification channel / chat: Hipchat
# Monitoring: 
# Metrics: grafana

file_anchorchain=anchor
dir_icons=/userContent/customIcon

# Anchor Chain file format:
# name, url, icon
# Site wide icons will be in userContent/customIcon

#if [ ! -f $file_anchorchain ]; then
  # Create new file
  # TODO: change to HERE doc
#  cat <<ANCHOR > $file_anchorchain
#Project-Jira	http://url.com	$dir_icons/jira.png
#Project-Confluence	http://url.com	$dir_icons/confluence.png
#Project-Hipchat	http://url.com	$dir_icons/hipchat.png
#Project-Grafana	http://url.com	$dir_icons/grafana.png
#ANCHOR

  echo -e "Project-Jira\thttp://url.com\t$dir_icons/jira.png" > $file_anchorchain
  echo -e "Project-Confluence\thttp://url.com\t$dir_icons/confluence.png" >> $file_anchorchain
  echo -e "Project-Hipchat\thttp://url.com\t$dir_icons/hipchat.png" >> $file_anchorchain
  echo -e "Project-Grafana\thttp://url.com\t$dir_icons/grafana.png" >> $file_anchorchain
#else
  # Update existing file

echo "DEBUG: custom-val={custom-val}"
echo "DEBUG: custom-obj={custom-obj}"
# Object is json array
frag1="'links'"
frag="{$frag1" # : 

json=$(echo "$frag : {custom-obj}}" | sed s/\'/\"/g)
echo "DEBUG: json=$json"
echo "$json" | jq '.'

if [ "{custom-val}" != "{custom-val}" ]; then
  echo "DEBUG: Got a value: {custom-val}"
fi
