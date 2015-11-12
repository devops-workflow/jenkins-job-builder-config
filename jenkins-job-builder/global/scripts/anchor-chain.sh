set +x
echo 'Creating/Updating AnchorChain file'
# Create or modify anchor chain file to create links for a job to its related resources
#
# Override file
#   The repository may contain an override sidebar links file. If it does,
#   this file will be processed instead to generate the anchor file
#   File Format: Title; url; icon filename (name only, no path)

# Ideas of things to link:
#-----------------
# Ticketing Project: Jira
# Documentation: Confluence
# Notification channel / chat: Hipchat
# Monitoring: 
# Metrics: grafana
#
# TODO:
#	Move links array to top template in JJB, may change how data structure is passed into script.
#		JJB doesn't support :(
#	Support for existing file in repo to override or merge with ones in JJB definition
#		DONE -override
#	DONE -Define file format for repo file - It should define name and link, but not icon. Script should add icon
#		except format includes icon
#	DONE -Support no data via JJB and doing nothing if all data sources are missing
#

file_anchorchain=anchor
file_override=sidebar-links.txt
dir_icons=/userContent/customIcon
dir_config=ci_data

# Anchor Chain file format:
# name <tab> url <tab> icon
# Site wide icons will be in userContent/customIcon

jjb_links="{anchorchain-links}"

if [ -f "$dir_config/$file_override" ]; then
  cp /dev/null $file_anchorchain
  while read line || [[ -n "$line" ]]; do
    title=$(echo $line | cut -d\; -f1)
    url=$(echo $line | cut -d\; -f2)
    icon=$(echo $line | cut -d\; -f3)
    echo -e "DEBUG: Anchor chain line: $title\t$url\t$dir_icons/$icon"
    echo -e "$title\t$url\t$dir_icons/$icon" >> $file_anchorchain
  done < "$dir_config/$file_override"
# elif [ ! -f $file_anchorchain ] && [ -n "$jjb_links" ]; then
elif [ -n "$jjb_links" ]; then
  # Create new file from JJB definition
  start=$(echo -e "\x7b")
  body=$(echo "'links' : $jjb_links" | sed s/\'/\"/g)
  end=$(echo -e "\x7d")
  json="$start $body $end"
  echo "DEBUG: json=$json"
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
fi
