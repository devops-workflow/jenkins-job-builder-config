#!/bin/bash
#
# Run Jenkins Job Builder
#
# 2 run modes:
#	1) system mode - build all jobs in this (jenkins-job-builder) repo
#	2) job mode - build jobs in a different repo with macros and templates from this repo
#
# Parameters:
#   Remote Job Name
#   Flush Cache
#   config file
#
# $0 NO-JOB [ <flush|use> [ <config file> ]
# $0 NO-JOB [ <config file> ]
# $0 <job name> [ <config file> ]


dir_config_job=ci_data
jjb_base=$WORKSPACE/jenkins-job-builder
jjb_global=$jjb_base/global
dir_jobs_base=$JENKINS_HOME/jobs
jjb_job=$WORKSPACE/jjb.log
CacheFlush=''

if [ $# -gt 1 ] && [ "$2" = "flush" ]; then
  CacheFlush='--flush-cache'
fi
if [ $# -gt 2 ] && [[ $2 =~ ^(flush|use)$ ]]; then
  jjb_config=$3
elif [ $# -gt 1 ] && ! [[ $2 =~ ^(flush|use)$ ]]; then
  jjb_config=$2
else
  jjb_config='/etc/jenkins_jobs/jenkins_jobs.ini'
fi
if [ ! -f "${jjb_config}" ]; then
  echo "ERROR: jjb config file does not exist: ${jjb_config}"
  exit 1
fi

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
    jenkins-jobs --conf ${jjb_config} update -r ${jjb_global}:${dir_job_jjb} | tee $jjb_log
  else
    echo "ERROR: Job's jjb directory not found! $dir_job_jjb"
    exit 3
  fi
else
  # System mode
  jenkins-jobs ${CacheFlush} --conf ${jjb_config} update -r $jjb_base
  # jenkins-jobs --conf ${jjb_config} update $(dirname $0)/jenkins-job-builder/
fi
