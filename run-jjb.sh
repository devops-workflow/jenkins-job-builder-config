#!/bin/bash
#
# Run Jenkins Job Builder
#
# 2 run modes:
#	1) system mode - build all jobs in this (jenkins-job-builder) repo
#	2) job mode - build jobs in a different repo with macros and templates from this repo

dir_config_job=ci_data
jjb_base=$WORKSPACE/jenkins-job-builder
jjb_global=$jjb_base/global
dir_jobs_base=$JENKINS_HOME/jobs
jjb_job=$WORKSPACE/jjb.log

if [ $# -gt 0 ] && [ "$1" != "NO-JOB" ]; then
  # Job Mode
  job=$1
  if [ -z "$JENKINS_HOME" ]; then
    echo "ERROR: Not running under Jenkins"
    exit 1
  fi
  if [ "$NODE_NAME" != "master" ]; then
    echo "ERROR: Not running on Jenkins Master"
    exit 2
  fi
  dir_job_jjb=$dir_jobs_base/$job/workspace/$dir_config_job/jjb
  if [ -d "$dir_job_jjb" ]; then
    jenkins-jobs --conf /etc/jenkins_jobs/jenkins_jobs.ini update -r ${jjb_global}:${dir_job_jjb} | tee $jjb_log
  else
    echo "ERROR: Job's jjb directory not found! $dir_job_jjb"
    exit 3
  fi
else
  # System mode
  jenkins-jobs --conf /etc/jenkins_jobs/jenkins_jobs.ini update -r $jjb_base
  # jenkins-jobs --conf /etc/jenkins_jobs/jenkins_jobs.ini update $(dirname $0)/jenkins-job-builder/
fi
