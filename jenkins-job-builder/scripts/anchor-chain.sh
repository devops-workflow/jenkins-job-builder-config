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

#  echo -e "Project-Jira\thttp://url.com\t$dir_icons/jira.png" > $file_anchorchain
#  echo -e "Project-Confluence\thttp://url.com\t$dir_icons/confluence.png" >> $file_anchorchain
#  echo -e "Project-Hipchat\thttp://url.com\t$dir_icons/hipchat.png" >> $file_anchorchain
#  echo -e "Project-Grafana\thttp://url.com\t$dir_icons/grafana.png" >> $file_anchorchain
#else
  # Update existing file

#echo "DEBUG: custom-val={custom-val}"
#echo "DEBUG: custom-obj={custom-obj}"
# Object is json array

start=$(echo -e "\x7b")
body=$(echo "'links' : {anchorchain-links}" | sed s/\'/\"/g)
end=$(echo -e "\x7d")
json="$start $body $end"
#echo "DEBUG: json=$json"
#echo "$json" | jq '.'
elements=$(( $(echo "$json" | jq '.links | length') - 1))
cp /dev/null $file_anchorchain
for Link in $(seq 0 $elements); do
  E=$(echo "$json" | jq ".links[$Link].link")
  #echo "Link $Link == $E"
  name=$(echo "$E" | grep '"name"' | cut -d: -f2 | sed 's/^[ ]*//;s/\"//g;s/,$//')
  url=$(echo "$E" | grep '"url"' | cut -d: -f2- | sed 's/^[ ]*//;s/\"//g;s/,$//')
  icon=$(echo "$E" | grep '"icon"' | cut -d: -f2 | sed 's/^[ ]*//;s/\"//g;s/,$//')
  echo -e "DEBUG: Anchor chain line: $name\t$url\t$dir_icons/$icon"
  echo -e "$name\t$url\t$dir_icons/$icon" >> $file_anchorchain
done

if [ "{custom-val}" != "{custom-val}" ]; then
  echo "DEBUG: Got a value: {custom-val}"
fi
