#!/bin/bash
#
# Docker image testing
#

echo "Starting Docker Image testing..."

tmpdir=tmp
dockerDir=.
dockerFile=${dockerDir}/Dockerfile
imageDir=output-images
reportsDir=reports
versionFile=${tmpdir}/version
GIT_URL="${GIT_URL%.git}"

mkdir -p ${tmpdir} ${reportsDir}

#repository=$(grep org.label-schema.name= ${dockerFile} | sed 's/.*="//;s/".*//')
#if [ -z "${repository}" ]; then
  gitRepo="${GIT_URL##*/}"
  gitOrg="${GIT_URL##*.com/}"
  gitOrg="${gitOrg%%/*}"
  repository="${gitOrg}/${gitRepo}"
  #echo "ERROR: No image name found in Dockerfile. Using: ${repository}"
#fi
VERSION=$(cat ${versionFile})
dockerImage="${repository}:${VERSION}"
dockerImageID=$(docker images --format '{{.ID}}' ${dockerImage})

# Save image to file for scanning tools
echo "Saving Docker Image..."
imageFilename="${repository//\//-}-${VERSION}.tar"
imageFile="${imageDir}/${imageFilename}"
mkdir -p ${imageDir}
docker save -o ${imageFile} ${repository}

###
### Image Scanning
###
printf "=%.s" {1..30}
echo -e "\n\nStarting Audit Scanning...\n"
printf "=%.s" {1..30}
echo

###
### lynis
###
printf "=%.s" {1..3}
echo -e "Running lynis...\n"
pushd ${tmpdir}
lynis --auditor Jenkins --cronjob audit dockerfile ../${imageFile}
popd
if [ -f /tmp/lynis-report.dat ]; then
  cp /tmp/lynis-report.dat ${reportsDir}/lynis-image.dat
fi

###
### dockerfile-lint
###
# Setup rule set
cat <<"RULES" >${tmpdir}/rules-image-org.label-schema.yaml
---
  profile:
    name: "org.schema-label"
    description: "Check required labels from label-schema.org specification in Docker image"
  line_rules:
    LABEL:
       paramSyntaxRegex: /.+/
       defined_namevals:
           org.label-schema.build-date:
             valueRegex: /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.*/
             message: "Build Date/Time in RFC 3339 format"
             level: "warn"
             required: true
             reference_url:
               - "http://label-schema.org/"
           org.label-schema.name:
             valueRegex: /[\w]+\/[\w]+/
             message: "Name of the image. Format: x/y"
             level: "warn"
             required: true
             reference_url:
               - "http://label-schema.org/"
           org.label-schema.description:
             valueRegex: /.+/
             message: "Description of the image"
             level: "warn"
             required: true
             reference_url:
               - "http://label-schema.org/"
           org.label-schema.vendor:
             valueRegex: /[\w]+.*/
             message: "Vendor name"
             level: "warn"
             required: true
             reference_url:
               - "http://label-schema.org/"
           org.label-schema.version:
             valueRegex: /\d+\.\d+.*/
             message: "Docker Image version"
             level: "warn"
             required: true
             reference_url:
               - "http://label-schema.org/"
           org.label-schema.vcs-ref:
             valueRegex: /[\w]+/
             message: "VCS commit reference"
             level: "warn"
             required: true
             reference_url:
               - "http://label-schema.org/"
           org.label-schema.vcs-url:
             valueRegex: /[\w]+.+/
             message: "VCS repo url"
             level: "warn"
             required: true
             reference_url:
               - "http://label-schema.org/"
           org.label-schema.schema-version:
             valueRegex: /\d+\.\d+/
             message: "Label schema version"
             level: "warn"
             required: true
             reference_url:
               - "http://label-schema.org/"
#           jenkins-job="${JOB_NAME}" \
#           jenkins-build="${BUILD_NUMBER}" \
#           jenkins-build-tag="${BUILD_TAG}" \
#           jenkins-build-url="${BUILD_URL}"
  required_instructions:
    -
      instruction: LABEL
      count: 1
      description: "Labels are required...."
      level: error
      message: "No LABELs are defined"
      reference_url:
        - "https://docs.docker.com/reference/builder/"
        - "#label"
RULES

ruleFile=lint_rules_image.yaml
cat <<"RULES" >${tmpdir}/${ruleFile}
---
  profile:
    name: "Default"
    description: "Default Profile. Checks basic syntax."
    includes:
      - rules-image-org.label-schema.yaml
  line_rules:
    #LABEL:
    #   paramSyntaxRegex: /.+/
    #   defined_namevals:

    FROM:
      paramSyntaxRegex: /^[\w./-]+(:[\w.]+)?(-[\w]+)?$/
      rules:
        -
          label: "is_latest_tag"
          regex: /latest/
          level: "error"
          message: "base image uses 'latest' tag"
          description: "using the 'latest' tag may cause unpredictable builds. It is recommended that a specific tag is used in the FROM line or *-released which is the latest supported release."
          reference_url:
            - "https://docs.docker.com/reference/builder/"
            - "#from"
          label: "no_tag"
          regex: /^[:]/
          level: "error"
          message: "No tag is used"
          description: "lorem ipsum tar"
          reference_url:
            - "https://docs.docker.com/reference/builder/"
            - "#from"
          label: "specified_registry"
          regex: /[\w]+?\.[\w-]+(\:|\.)([\w.]+|(\d+)?)([/?:].*)?/
          level: "info"
          message: "using a specified registry in the FROM line"
          description: "using a specified registry may supply invalid or unexpected base images"
          reference_url:
            - "https://docs.docker.com/reference/builder/"
            - "#entrypoint"
    MAINTAINER:
      paramSyntaxRegex: /.+/
      rules: []
    RUN:
      paramSyntaxRegex: /.+/
      rules:
        -
          label: "no_yum_clean_all"
          regex: /yum(?!.+clean all|.+\.repo|-config|\.conf)/
          level: "warn"
          message: "yum clean all is not used"
          description: "the yum cache will remain in this layer making the layer unnecessarily large"
          reference_url:
            - "http://docs.projectatomic.io/container-best-practices/#"
            - "_clear_packaging_caches_and_temporary_package_downloads"
        -
          label: "yum_update_all"
          regex: /yum(.+update all|.+upgrade|.+update)/
          level: "info"
          message: "updating the entire base image may add unnecessary size to the container"
          description: "update the entire base image may add unnecessary size to the container"
          reference_url:
            - "http://docs.projectatomic.io/container-best-practices/#"
            - "_clear_packaging_caches_and_temporary_package_downloads"
        -
          label: "no_dnf_clean_all"
          regex: /dnf(?!.+clean all|.+\.repo)/g
          level: "warn"
          message: "dnf clean all is not used"
          description: "the dnf cache will remain in this layer making the layer unnecessarily large"
          reference_url:
            - "http://docs.projectatomic.io/container-best-practices/#"
            - "_clear_packaging_caches_and_temporary_package_downloads"
        -
          label: "no_rvm_cleanup_all"
          regex: /rvm install(?!.+cleanup all)/g
          level: "warn"
          message: "rvm cleanup is not used"
          description: "the rvm cache will remain in this layer making the layer unnecessarily large"
          reference_url:
            - "http://docs.projectatomic.io/container-best-practices/#"
            - "_clear_packaging_caches_and_temporary_package_downloads"
        -
          label: "no_gem_clean_all"
          regex: /gem install(?!.+cleanup|.+\rvm cleanup all)/g
          level: "warn"
          message: "gem cleanup all is not used"
          description: "the gem cache will remain in this layer making the layer unnecessarily large"
          reference_url:
            - "http://docs.projectatomic.io/container-best-practices/#"
            - "_clear_packaging_caches_and_temporary_package_downloads"
        -
          label: "no_apt-get_clean"
          regex: /apt-get install(?!.+clean)/g
          level: "info"
          message: "apt-get clean is not used"
          description: "the apt-get cache will remain in this layer making the layer unnecessarily large"
          reference_url:
            - "http://docs.projectatomic.io/container-best-practices/#"
            - "_clear_packaging_caches_and_temporary_package_downloads"
        # no_npm_clean
        ## npm cache clean
        #   regex: /npm install(?!.+cache clean)/g
        # no_pip_clean
        ## rm -rf .cache/pip/*
        #   regex: /pip install(?!.+rm -rf.+\.cache\/pip)/g
        # no_cpan_clean
        ## rm -rf .cpan/{build,sources}/*
        -
          label: "privileged_run_container"
          regex: /privileged/
          level: "warn"
          message: "a privileged run container is allowed access to host devices"
          description: "Does this run need to be privileged?"
          reference_url:
            - "http://docs.docker.com/engine/reference/run/#"
            - "runtime-privilege-and-linux-capabilities"
        -
          label: "installing_ssh"
          regex: /openssh-server/
          level: "warn"
          message: "installing SSH in a container is not recommended"
          description: "Do you really need SSH in this image?"
          reference_url: "https://github.com/jpetazzo/nsenter"
        -
          label: "no_ampersand_usage"
          regex: / ; /
          level: "info"
          message: "using ; instead of &&"
          description: "RUN do_1 && do_2: The ampersands change the resulting evaluation into do_1 and then do_2 only if do_1 was successful."
          reference_url:
            - "http://docs.projectatomic.io/container-best-practices/#"
            - "#_using_semi_colons_vs_double_ampersands"
    EXPOSE:
      paramSyntaxRegex: /^[\d-\s\w/\\]+$/
      rules: []
    ENV:
      paramSyntaxRegex: /^[\w-$/\\=\"[\]{}@:,'`\t. ]+$/
      rules: []
    ADD:
      paramSyntaxRegex: /^~?([\w-.~:/?#\[\]\\\/*@!$&'()*+,;=.{}"]+[\s]*)+$/
    COPY:
      paramSyntaxRegex: /.+/
      rules: []
    ENTRYPOINT:
      paramSyntaxRegex: /.+/
      rules: []
    VOLUME:
      paramSyntaxRegex: /.+/
      rules: []
    USER:
      paramSyntaxRegex: /^[a-z0-9_][a-z0-9_]{0,40}$/
      rules: []
    WORKDIR:
      paramSyntaxRegex: /^~?[\w\d-\/.{}$\/:]+[\s]*$/
      rules: []
    ONBUILD:
      paramSyntaxRegex: /.+/
      rules: []
  required_instructions:
#    -
#      instruction: "MAINTAINER"
#      count: 1
#      level: "info"
#      message: "Maintainer is not defined"
#      description: "The MAINTAINER line is useful for identifying the author in the form of MAINTAINER Joe Smith <joe.smith@example.com>"
#      reference_url:
#        - "https://docs.docker.com/reference/builder/"
#        - "#maintainer"
#    -
#      instruction: "EXPOSE"
#      count: 1
#      level: "info"
#      message: "There is no 'EXPOSE' instruction"
#      description: "Without exposed ports how will the service of the container be accessed?"
#      reference_url:
#        - "https://docs.docker.com/reference/builder/"
#        - "#expose"
#    -
#      instruction: "CMD"
#      count: 1
#      level: "info"
#      message: "There is no 'CMD' instruction"
#      description: "None"
#      reference_url:
#        - "https://docs.docker.com/reference/builder/"
#        - "#cmd"
RULES

# Create jq parser for creating Jenkins Warning plugin output
parserFile=parse-dockerfile-lint.jq
cat <<"PARSER" >${tmpdir}/${parserFile}
#
# jq filter for parsing dockerfile-lint output into 1 liners that Jenkins Warning plugin can parse
#
# Arguments:
#   file        relative path to Dockerfile or image
#
# Written for jq 1.5
# Author: Steven Nemetz
#
# Output format:
#  filename:priority:line number:category:message
#
.[].data?[]
 | "\($file):\(.level):" +
   if .line > 0 then
     "\(.line)"
   else
     "0"
   end +
   ":" +
   if .instruction then
     "\(.instruction)"
   elif .label then
     "\(.label)"
   else
     "misc"
   end +
   ":" +
   # Form message field by combining: message, description, reference_url array, and lineContent
   # Might reformat this later
   "\(.message)" +
   if .lineContent and (.lineContent | length > 0) then
     " Line=\(.lineContent)"
   else
     ""
   end +
   if .description then
     " Reason=\(.description)"
   else
     ""
   end +
   if .reference_url then
     " Reference=" + (.reference_url | join(""))
   else
     ""
   end
PARSER

printf "=%.s" {1..3}
echo "Running dockerfile-lint..."
docker run -i --rm --privileged -v `pwd`:/root/ -v /var/run/docker.sock:/var/run/docker.sock projectatomic/dockerfile-lint dockerfile_lint -p -r ${tmpdir}/${ruleFile} image ${dockerImageID}
docker run -i --rm --privileged -v `pwd`:/root/ -v /var/run/docker.sock:/var/run/docker.sock projectatomic/dockerfile-lint dockerfile_lint -p -j -r ${tmpdir}/${ruleFile} image ${dockerImageID} > ${reportsDir}/dockerfile-lint-image.json
# use -j to get json output
jq --arg file ${dockerFile} -f ${tmpdir}/${parserFile} ${reportsDir}/dockerfile-lint-image.json > ${reportsDir}/dockerfile-lint-image.warnings
if [ ! -s ${reportsDir}/dockerfile-lint-image.warnings ]; then
  rm -f ${reportsDir}/dockerfile-lint-image.warnings
fi

###
### Clair
###
# Install
#  use docker-compose or manual and can have central Clair server
if [ $(docker ps --format '{{.ID}}' --filter name=clair_postgres | wc -l) -eq 0 ]; then
  ###
  ### Create postgres container
  ###
  #docker pull postgres:latest
  docker run -d --name clair_postgres -e POSTGRES_PASSWORD=password postgres:latest
fi

if [ $(docker ps --format '{{.ID}}' --filter name=clair_clair | wc -l) -eq 0 ]; then
  ###
  ### Create Clair container
  ###
  # Do not try to use latest with config from master
  clair_version=v1.2.3
  clair_config_dir="${WORKSPACE%%/workspace*}/clair_config"
  TMPDIR=
  mkdir -p ${clair_config_dir}
  curl -L https://raw.githubusercontent.com/coreos/clair/${clair_version}/config.example.yaml -o ${clair_config_dir}/config.yaml
  sed -i '/ source:/ s#:.*#: postgresql://postgres:password@postgres:5432?sslmode=disable#' ${clair_config_dir}/config.yaml
  #docker pull quay.io/coreos/clair:${clair_version}
  docker run -d --name clair_clair -p 6060-6061:6060-6061 --link clair_postgres:postgres -v /tmp:/tmp -v ${clair_config_dir}:/config quay.io/coreos/clair:${clair_version} -config=/config/config.yaml
fi

install_dir="${WORKSPACE%%/workspace*}/bin"
if [ ! -x ${install_dir}/hyperclair ]; then
  ###
  ### Install hyperclair
  ###
  # write code to determine and get latest
  # Could eventually change to clairctl in clair
  hyperclair_version=0.5.2
  mkdir -p ${install_dir}
  # sudo curl -L -o ${install_dir}/hyperclair  https://github.com/wemanity-belgium/hyperclair/releases/download/0.5.0/hyperclair-{OS}-{ARCH}
  curl -L -o ${install_dir}/hyperclair  https://github.com/wemanity-belgium/hyperclair/releases/download/${hyperclair_version}/hyperclair-linux-amd64
  chmod +x ${install_dir}/hyperclair
  # Create config file (optional)
#  cat <<HYPERCLAIR > ${install_dir}/../.hyperclair.yml
#clair:
#  port: 6060
#  healthPort: 6061
#  uri: http://127.0.0.1
#  priority: Low
#  report:
#    path: ./reports
#    format: html
#HYPERCLAIR
fi
# Run hyperclair - analyse image and generate report - Have jenkins consume report (formats?)
# Config file setup ??
${install_dir}/hyperclair version
${install_dir}/hyperclair health
# If clair is NOT healthy, wait for a while
#${install_dir}/hyperclair -h
echo
printf "=%.s" {1..3}
echo -e "Running Clair CLI hyperclair...\n"
echo "CMD: hyperclair push|analyse|report ${dockerImage} --local"
${install_dir}/hyperclair push ${dockerImage} --local
${install_dir}/hyperclair analyse ${dockerImage} --local
${install_dir}/hyperclair report ${dockerImage} --local --format html
# Create json output and parse to get into Jenkins GUI
${install_dir}/hyperclair report ${dockerImage} --local --format json
# Report at reports/html/analyse-<image name>-<tag|latest>.html
#--config ${install_dir}/../.hyperclair.yml
# Can query json with jq
# Number of vulnerabilities found. List of all the CVEs
#jq '.Layers[].Layer.Features[].Vulnerabilities[].Name' analysis-intel-fenix-0.0-636-3edcab1.json 2>/dev/null | sort -u | wc -l
#jq '.Layers[].Layer.Features[].Vulnerabilities[].Severity' analysis-intel-fenix-0.0-636-3edcab1.json 2>/dev/null | wc -l
# List of all package names
#jq '.Layers[].Layer.Features[].Name' | sort -u

# Create jq parser for creating Jenkins Warning plugin output
parserFile=parse-hyperclair.jq
cat <<"PARSER" >${tmpdir}/${parserFile}
#
# jq filter for parsing hyperclair output into 1 liners that Jenkins Warning plugin can parse
#
# Written for jq 1.5
# Author: Steven Nemetz
#
# Output format:
#  filename;line number;category;type;priority;message
#
# Set to variable, then reference after if
# Got lost because of piping a lower level
#.filename = "\(.ImageName):\(.Tag)"
# | (.Layers[].Layer.Features[]
#
# First line is bad. So pipe to
# Will create duplicate and bad lines
# Need to pipe output to cleanup or figure out better way to do this
# | sort -u | tail -n+2
"\(.ImageName):\(.Tag);0;" +
(.Layers[].Layer.Features[]
  | if .Vulnerabilities then
      "\(.Name) - \(.Version);" +
      (.Vulnerabilities[] | "\(.Name);\(.Severity);" +
      if .Message then
        "\(.Message) "
      else
        ""
      end +
      "Reference: \(.Link)")
    else
      ""
    end
 )
PARSER
# reformat dockerImage - x/y:ver -> x-y-ver - s/[/:]/-/g
filenameBase="analysis-$(echo ${dockerImage} | sed 's#[/:]#-#g')"
jq -f ${tmpdir}/${parserFile} ${reportsDir}/json/${filenameBase}.json | sort -u | tail -n+2 > ${reportsDir}/${filenameBase}.warnings
if [ ! -s ${reportsDir}/${filenameBase}.warnings ]; then
  rm -f ${reportsDir}/${filenameBase}.warnings
fi

#export GODIR="${WORKSPACE%%/workspace*}/go"
#export GOPATH=$GODIR:/usr/lib/go-1.6
#if [ ! -x ${GODIR}/bin/analyze-local-images ]; then
#  ###
#  ### Install analyze-local-images
#  ###
#  #export GOBIN=
#  /usr/lib/go-1.6/bin/go get -u github.com/coreos/clair/contrib/analyze-local-images
#  $GODIR/bin/analyze-local-images -h || true
#fi
## Run analyze-local-images
#echo
#printf "=%.s" {1..3}
#echo -e "Running Clair CLI analyze-local-images...\n"
#echo "CMD: analyze-local-images ${dockerImage}"
#$GODIR/bin/analyze-local-images ${dockerImage}
## Write Jenkins Warning parser for output if decide to continue with this cli tool

# Can also write own tool to talk with Clair API

###
### BanyanOps Collector
###
# Documentation: https://hub.docker.com/r/banyanops/collector/
#
# Not sure this does anythng useful without adding scripts. Need to look at more
#
#  Environment variables:
#    COLLECTOR_DIR:   (Required) Directory that contains the "data" folder with Collector default scripts, e.g., $GOPATH/src/github.com/banyanops/collector
#    COLLECTOR_ID:    ID provided by Banyan web interface to register Collector with the Banyan service
#    BANYAN_HOST_DIR: Host directory mounted into Collector/Target containers where results are stored (default: $HOME/.banyan)
#    BANYAN_DIR:      (Specify only in Dockerfile) Directory in the Collector container where host directory BANYAN_HOST_DIR is mounted
#    DOCKER_{HOST,CERT_PATH,TLS_VERIFY}: If set, e.g., by docker-machine, then they take precedence over --dockerProto and --dockerAddr

#docker pull banyanops/collector
#docker run --rm \
#-v ~/.docker:/root/.docker \
#-v ~/.dockercfg:/root/.dockercfg \
#-v /var/run/docker.sock:/var/run/docker.sock \
#-v $HOME/.banyan:/banyandir \
#-v <USER_SCRIPTS_DIR>:/banyancollector/data/userscripts \
#-e BANYAN_HOST_DIR=$HOME/.banyan \
#banyanops/collector local.host <REPO>

#docker run --rm banyanops/collector -h

#docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.banyan:/banyandir -e BANYAN_HOST_DIR=$HOME/.banyan banyanops/collector local.host snemetz/test
#docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.banyan:/banyandir -e BANYAN_HOST_DIR=/banyandir banyanops/collector local.host snemetz/test

echo "Finished Docker Image testing."
