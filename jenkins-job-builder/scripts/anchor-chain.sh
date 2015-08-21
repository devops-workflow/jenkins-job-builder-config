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
# name <tab> url <tab> icon
# Site wide icons will be in userContent/customIcon

#if [ ! -f $file_anchorchain ]; then
  # Create new file

# Create or replace any existing file
start=$(echo -e "\x7b")
body=$(echo "'links' : {anchorchain-links}" | sed s/\'/\"/g)
end=$(echo -e "\x7d")
json="$start $body $end"
#echo "DEBUG: json=$json"
#echo "$json" | jq '.'
elements=$(( $(echo "$json" | jq '.links | length') - 1))
cp /dev/null $file_anchorchain
for I in $(seq 0 $elements); do
  link=$(echo "$json" | jq ".links[$I].link")
  #echo "Link $I == $link"
  name=$(echo "$link" | grep '"name"' | cut -d: -f2 | sed 's/^[ ]*//;s/\"//g;s/,$//')
  url=$(echo "$link" | grep '"url"' | cut -d: -f2- | sed 's/^[ ]*//;s/\"//g;s/,$//')
  icon=$(echo "$link" | grep '"icon"' | cut -d: -f2 | sed 's/^[ ]*//;s/\"//g;s/,$//')
  echo -e "DEBUG: Anchor chain line: $name\t$url\t$dir_icons/$icon"
  echo -e "$name\t$url\t$dir_icons/$icon" >> $file_anchorchain
done

#else
  # Update existing file
