# Create Project Description
set +x
echo 'Building Project Description'
cat <<DESC > project_description
Project for testing puppet module $JOB_NAME
<p>
Current tests:<br>
Files Exists, Syntax, Style, Doc, Unit Tests
<p>
Last run on: `date`
DESC
