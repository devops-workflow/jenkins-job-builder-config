set +x
# Create Project Description
# Features:
#	Options to load header, body, and/or footer from repo
#	- process all variables

desc_header=desc-header.txt
desc_body=desc-body.txt
desc_footer=desc-footer.txt
dir_config=ci_data
file_desc=project_description


replace_vars() {
  # usage: replace_vars file.tpl
  while IFS= read -r line ; do
    line=${line//\"/\\\"}   # Prevent " issues
    line=${line//\`/\\\`}   # Prevent backtick processing
    line=${line//\$/\\\$}   # Prevent $ processing
    line=${line//\\\${/\${} # Allow ${} processing
    eval "printf '%s\n' \"$line\"";
  done < "${1}"
}

echo 'Building Project Description...'
if [ -f "$dir_config/$desc_header" ]; then
  replace_vars "$dir_config/$desc_header" > $file_desc
else
  cp /dev/null $file_desc
fi

if [ -f "$dir_config/$desc_body" ]; then
  replace_vars "$dir_config/$desc_body" >> $file_desc
else
  cat <<DESC >> $file_desc
Project for testing module $JOB_NAME
<p>
Last run on: `date`
DESC
fi

if [ -f "$dir_config/$desc_footer" ]; then
  replace_vars "$dir_config/$desc_footer" >> $file_desc
fi
