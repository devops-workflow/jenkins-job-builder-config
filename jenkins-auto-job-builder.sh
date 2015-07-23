#!/usr/local/bin/bash
#
# Automatically define jenkin jobs based on repositories in a github organization
#
# What comes after the repo pattern is used for the jenkins job name
#
# Requirements:
#   For validating file contents
#	jq - https://stedolan.github.io/jq/

# TODO: make these parameters and support a config file
token=
# domain=github.com
org=devops-workflow
repo_pattern=puppet_module_
jjb_projects=Puppet_Modules_project.yaml		# Full project list definitions file
jjb_template=puppet-module-project-template.yaml	# Template file for creating new projects
url_api="https://api.github.com"
url_web="https://github.com"
validate_file=manifests/init.pp
validate_skip_on_fail=0
dir_templates=config
dir_projects=jenkins-job-builder
path_template=${dir_templates}/${jjb_template}
path_projects=${dir_projects}/${jjb_projects}

# Without token is fine for read. When supporting writes will need to require if write operations are requested
if [ -z "$token" ]; then
  auth=''
else
  auth="-H 'Authorization: token $token'"
fi

# Get Jenkins job list from JJB yaml
declare -A existing_jobs
if [ -f ${path_projects} ]; then
   # Read job/repo list
   for R in $(grep repo_name: ${path_projects} | awk '{ print $2 }'); do
     existing_jobs[$R]=1
   done
fi

# Get list of repositories
echo "Processing organization: $org"
for REPO in $(curl -s -k $auth $url_api/users/$org/repos  | grep \"name\": | sed s/\"name\":\ \"//g | sed s/\",//g); do
  echo "Processing: ${REPO}"
  if ! [[ $REPO =~ $repo_pattern ]]; then
    # Skip if does not match repository name pattern
    continue
  fi
  if [ -n "${existing_jobs[$REPO]}" ]; then
    # Skip if already have a job defined for the repository
    echo "Job exists: $REPO"
    continue
  fi
  # Validate repository
  # TODO: possible option to check multiple files
  # TODO: Somehow allow what to validate and the error message to be specified
  # Validate the file exists in the repository
  #   curl -s -k https://api.github.com/repos/devops-workflow/puppet_module_site_workflow/contents/README.md
  #  Returns json info about file and how to download it (download_url)
  j=$(curl -s -k $auth $url_api/repos/$org/$REPO/contents/$validate_file | { grep \"message\":\ \"Not\ Found\" || true; })
  if [[ -n $j ]]; then
    echo "WARNING: $REPO does not appear to be a Puppet Module"
    if [ $validate_skip_on_fail == '1' ]; then
      # Skip if validation file does not exist
      continue
    fi
  # else # Option to check contents of file
    # j=$(curl -s -k $auth $url_api/repos/$org/$REPO/contents/$validate_file | grep \"download_url\" | 
    # curl -s -k https://api.github.com/repos/devops-workflow/puppet_module_site_workflow/contents/README.md | ./jq '.download_url' | sed 's/"//g'
  fi

  # Define Job
  NAME=${REPO:${#repo_pattern}}
  #echo "Defining job '$NAME' for repo '$REPO'"
  # Reading template, replacing content, then appending to project file
  cat ${path_template} | sed "s#-NAME-#$NAME#;s#-REPO-#$REPO#;s#-URL_WEB-#$url_web#;s#-ORG-#$org#" >>${path_projects}

  # TODO: Update repo (write): readme file, setup webhook, 
  echo "Done adding: $REPO"
done

# Update git
#git add ${path_projects}
#git commit -m 'Add jobs for new repositories'
#git push
# Trigger JJB run
# TODO: define job in JJB to run JJB, needs to have url trigger

exit

# Filter repository list by regex
# Read project list from JJB yaml (or optional jenkin API)
# Compare repositories to existing jobs
# For any repository without a job
#    validate repo is puppet module: manifests/init.pp exists
#    define job in JJB yaml - commit to repo
#    update README with Build badge, setup hook - commit to repo
#    trigger jenkins job to run JJB

