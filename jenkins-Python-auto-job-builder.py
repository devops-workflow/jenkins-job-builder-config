#!/usr/bin/env python
#
# Automatically define jenkin jobs based on repositories in a github organization
#
# TODO:
#	make project variables parameters and support a config file
#	create wrapper script to run with multiple config file. 2 parameters: config file dir & config file name pattern
#	Idea: have a dir of config files & templates. Wrapper processes all config files found.
#   Option for processing, status, and results msgs or not
#   Option to build jobs for all branches or some (Specified how?) - How to name and organize in UI?

# Look at using PyGithub - from github import GitHub
# or libsaas
import argparse
import json
import re
import requests
import yaml

verbose               = False
# TODO: put in config file and cmd line args
token                 = ''
org                   = 'devops-workflow'
repo_pattern          = '.*' # TODO: Add capture group for Job name
jjb_projects          = 'projects_devops.yaml'         # Full project list definitions file
jjb_template          = 'project-template-devops.yaml'	# Template file for creating new projects
url_api               = 'https://api.github.com'
url_web               = 'https://github.com'
validate_files        = ['requirements.txt', 'setup.py']
# END config file required data
validate_skip_on_fail = True
dir_templates         = 'config'
dir_projects          = 'jenkins-job-builder'
path_template         = '%s/%s' % (dir_templates, jjb_template)
path_projects         = '%s/%s' % (dir_projects, jjb_projects)
existing_jobs         = {}
metric_repo           = 0
metric_repo_branches  = 0
metric_jobs           = 0
metric_jobs_created   = 0
metric_skip_pattern   = 0
metric_skip_validation= 0

# File may not exist - Can continue
projects = yaml.load(file(path_projects, 'r'))
# TODO: need list of existing jobs and branches (github-branch)
for project in projects:
    existing_jobs[project['project']['github-repo']] = 1
    #existing_jobs[project['project']['github-repo']-project['project']['github-branch']] = 1
# File may not exist - Fail
template = yaml.load(file(path_template, 'r'))
template[0]['project']['github-url'] = url_web
template[0]['project']['github-org'] = org
template[0]['project']['node'] = org
template[0]['project']['project'] = org.upper()

print 'Processing organization: %s' % org
# TODO: support with (private repos) or without token (public repos only)
header_auth = { 'Authorization': 'token %s' % token }
processing_repos = True
repo_link = '%s/users/%s/repos' % (url_api, org)
repo_params = {'per_page':'100'}
while processing_repos:
    ### Handle multiple pages of repositories
    http_response = requests.get(repo_link, params=repo_params, headers=header_auth, verify=False)
    if verbose : print 'Processing url: %s' % http_response.url
    processing_repos = False
    if 'link' in http_response.headers :
        for link in http_response.headers['link'].split(','):
            l = link.split('; ')
            if l[1] == 'rel="next"' :
                repo_link = l[0].split('?')[0][1:]
                for param in l[0].split('?')[1].split('&'):
                    if param[-1] == '>' :
                        param = param[:-1]
                        repo_params[param.split('=')[0]] = param.split('=')[1]
                        processing_repos = True
                        break
    #print 'Content-Type: %s' % http_response.headers['content-type']
    # if application/json
    ### Process the repositories
    for repo in http_response.json():
        print 'Processing repo: %s' % repo['full_name']
        metric_repo += 1
        ### Check repo matches pattern of repos to process
        match = re.match(repo_pattern, repo['name'])
        if not match:
            if verbose : print '\tSKIP: Does not match pattern: %s' % repo_pattern
            metric_skip_pattern += 1
            continue
        ### Process all repo branches
        # TODO: build jobs for each branch base on some criteria. Same validation as repo?
        branch_reponse = requests.get(repo['branches_url'].replace('{/branch}', ''), headers=header_auth, verify=False)
        branches = 0
        for branch in branch_reponse.json():
            if branch != "gh_pages":
                branches += 1
                metric_repo_branches += 1
                # TODO: move full repo validation and processing here
        print '\tBranches: %s' % branches
        # Fields: name, full_name, url, contents_url, download_url, updated_at, pushed_at, language
        # TODO: change to match job and branch
        if repo['name'] in existing_jobs:
            if verbose : print '\tSKIP: Job exists for %s' % repo['name']
            metric_jobs += 1
            continue
        # job name = match.group(1) # First capture group
        if verbose : print '\tAnalyzing %s' % repo['name']
        ### Validate repo and branch
        # TODO: Somehow allow what to validate and the error message to be specified
        found_file = False
        for validate_file in validate_files:
            r = requests.get(repo['contents_url'].replace('{+path}', validate_file), headers=header_auth, verify=False)
            if r.status_code != 200 : continue
            found_file = True
            # TODO: Option: download & check contents of file. Do separately? Different files different content
            break
        # Possibly search repo for file extensions: *.py
        # List files in GitHub repo:
        #   url_api + /repos/ + org + / + repo + /git/trees/master?recursive=1
        # Returns json ['tree'][array of file paths]['path']
        # ...['type'] blob|tree(is dir)

        if validate_skip_on_fail and not found_file :
            if verbose : print '\tSKIP: No validation file found'
            metric_skip_validation += 1
            continue
        ### Define job
        print '\tCreating JJB job for: %s' % repo['name']
        # Can use var.encode or str(var)
        template[0]['project']['name'] = repo['name'].encode('ascii','ignore')
        template[0]['project']['github-repo'] = repo['name'].encode('ascii','ignore')
        #template[0]['project']['github-branch'] = branch.encode('ascii','ignore')
        #print yaml.dump(template, default_flow_style=False)
        yaml.dump(template, open(path_projects, 'a'), default_flow_style=False)
        metric_jobs += 1
        metric_jobs_created += 1
        print '\tDone adding: %s' % repo['name']

print '''\nMetrics for Organization %s with pattern "%s":
\tTotal Repositories: %6d
\tTotal Repo Branches: %5d
\tTotal Jenkins Jobs: %6d
\tNew Jobs: %16d
\tSkipped Pattern: %9d
\tSkipped Validation: %6d''' % \
    (org, repo_pattern, metric_repo, metric_repo_branches, metric_jobs, metric_jobs_created, metric_skip_pattern, metric_skip_validation)
# TODO: Update git
#git add ${path_projects}
#git commit -m 'Add jobs for new repositories'
#git push
# trigger JJB run
# TODO: define job in JJB to run JJB, needs to have url trigger
