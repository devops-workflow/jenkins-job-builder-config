#!/bin/bash

# Run Jenkins Job Builder

#cd /etc/jenkins_jobs/jobs/
#jenkins-jobs --conf ../jenkins_jobs.ini -l DEBUG  update .
#jenkins-jobs --conf ../jenkins_jobs.ini update .

jenkins-jobs --conf /etc/jenkins_jobs/jenkins_jobs.ini update jenkins-job-builder/
