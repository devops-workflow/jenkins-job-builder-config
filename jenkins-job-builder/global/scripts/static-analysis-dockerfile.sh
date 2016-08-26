#!/bin/bash
#
# Dockerfile testing
#
# Known test programs:
#  dockerfile-lint         https://github.com/projectatomic/dockerfile_lint
#    - This should be run on Dockerfile and image with different rule sets
#  dockerfile-validator
#  dockerlint              https://github.com/redcoolbeans/dockerlint
#  hadolint
#  validate-dockerfile

printf "=%.s" {1..30}
echo -e "\nStarting Dockerfile testing..."
printf "=%.s" {1..30}
echo

tmpdir=tmp
dockerDir=.
dockerFile=${dockerDir}/Dockerfile
reportsDir=reports

mkdir -p ${tmpdir}
mkdir -p ${reportsDir}

###
### dockerlint
###
printf "=%.s" {1..3}
echo -e "Running dockerlint...\n"
docker run -i --rm redcoolbeans/dockerlint -h | head -n 1
docker run -i --rm -v "${WORKSPACE}/${dockerFile}":/Dockerfile:ro redcoolbeans/dockerlint
# Fix issue with errors with comments before FROM. If # doesn't have a whitespace after it. Needs to have space or tab.
# It is splitting on [ \t] then testing first item, instead of testing first char in line.
# Might also have issues with comments on same line as instructions. Need to test
# -p to treat warnings as errors

###
### lynis
###
printf "=%.s" {1..3}
echo -e "Running lynis...\n"
pushd ${tmpdir}
lynis --auditor Jenkins --cronjob audit dockerfile ../${dockerFile}
popd
if [ -f /tmp/lynis-report.dat ]; then
  cp /tmp/lynis-report.dat ${reportsDir}/lynis-dockerfile.dat
fi

###
### dockerfile-lint
###
# Setup rule set
# TODO: customize this for us. Test for all labels that we require
cat <<"RULES" >${tmpdir}/rules-dockerfile-org.label-schema.yaml
---
  profile:
    name: "org.schema-label"
    description: "Check required labels from label-schema.org specifications"
  line_rules:
    LABEL:
       paramSyntaxRegex: /.+/
       defined_namevals:
           org.label-schema.build-date:
             valueRegex: /\${\w+}/
             message: "Build Date/Time must be a variable in Dockerfile source for build process to provide value"
             level: "warn"
             required: true
             reference_url:
               - "http://label-schema.org/"
           org.label-schema.name:
             # Have build process provide as GitOrg/GitRepo
             valueRegex: /\${\w+}/
             message: "Name of the image must be a variable in Dockerfile source for build process to provide value"
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
             valueRegex: /\${\w+}/
             message: "Docker Image version must be a variable in Dockerfile source for build process to provide value"
             level: "warn"
             required: true
             reference_url:
               - "http://label-schema.org/"
           org.label-schema.vcs-ref:
             valueRegex: /\${\w+}/
             message: "VCS commit reference must be a variable in Dockerfile source for build process to provide value"
             level: "warn"
             required: true
             reference_url:
               - "http://label-schema.org/"
           org.label-schema.vcs-url:
             valueRegex: /\${\w+}/
             message: "VCS repo url must be a variable in Dockerfile source for build process to provide value"
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
    ARG:
      paramSyntaxRegex: /^\w+=?.+$/
      rules:
        -
          label: "default_value"
          regex: /[=]/
          level: "error"
          inverse_rule: true
          message: "Default values are required"
          description: "All ARG statements must have default values. That way that are not required build arguments for development"
          #reference_url:
  required_instructions:
    -
      instruction: ARG
      count: 1
      description: "ARG statements are required for dynamic variables"
      level: error
      message: "No ARGs are defined"
      #reference_url:
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

ruleFile=lint_rules_dockerfile.yaml
cat <<"RULES" >${tmpdir}/${ruleFile}
---
  profile:
    name: "Default"
    description: "Default Profile. Checks basic syntax."
    includes:
      - rules-dockerfile-org.label-schema.yaml
  line_rules:
    #LABEL:
    #   paramSyntaxRegex: /.+/
       # Use defined_label_rules to defined a set of labels for your dockerfile
       # In this example, the labels "Vendor","Authoritative_Registry","BZComponent"
       # have been defined. A label value is 'valid' if matches the regular
       # expression 'valueRegex', otherwise an warn is logged with the string "message"
       # at level 'level'.  'reference_url' provides a web link where the user can
       # get more information about the rule.
       #
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
        #
        # OS Packaging cleanup rules
        #
        # RedHat (RPM)
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
        # Debian, Ubuntu (DEB)
        -
          label: "no_apt-get_clean"
          # use clean and autoclean ??
          regex: /apt-get install(?!.+clean)/g
          level: "info"
          message: "apt-get clean is not used"
          description: "the apt-get cache will remain in this layer making the layer unnecessarily large"
          reference_url:
            - "http://docs.projectatomic.io/container-best-practices/#"
            - "_clear_packaging_caches_and_temporary_package_downloads"
        # Alpine (apk)
        ## rm -rf /var/cache/apk/*
        #
        # Language Packaging cleanup rules
        #
        # Ruby
        # TODO: installing gems without doc or code to remove doc afterwards
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
        # NodeJS
        # no_npm_clean
        ## npm cache clean
        #   regex: /npm install(?!.+cache clean)/g
        # Python
        # no_pip_clean
        ## rm -rf .cache/pip/*
        #   regex: /pip install(?!.+rm -rf.+\.cache\/pip)/g
        # Perl
        # no_cpan_clean
        ## rm -rf .cpan/{build,sources}/*
        # General cleaning
        ## rm -rf /usr/share/doc
        ## rm -rf /tmp/* /var/tmp/*
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
    -
      instruction: "MAINTAINER"
      count: 1
      level: "info"
      message: "Maintainer is not defined"
      description: "The MAINTAINER line is useful for identifying the author in the form of MAINTAINER Joe Smith <joe.smith@example.com>"
      reference_url:
        - "https://docs.docker.com/reference/builder/"
        - "#maintainer"
    -
      instruction: "EXPOSE"
      count: 1
      level: "info"
      message: "There is no 'EXPOSE' instruction"
      description: "Without exposed ports how will the service of the container be accessed?"
      reference_url:
        - "https://docs.docker.com/reference/builder/"
        - "#expose"
    -
      instruction: "CMD"
      count: 1
      level: "info"
      message: "There is no 'CMD' instruction"
      description: "None"
      reference_url:
        - "https://docs.docker.com/reference/builder/"
        - "#cmd"
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
#docker run -i --rm --privileged projectatomic/dockerfile-lint dockerfile_lint -h
# No version available from app or image tags
docker run -i --rm --privileged -v `pwd`:/root/ -v /var/run/docker.sock:/var/run/docker.sock projectatomic/dockerfile-lint dockerfile_lint -p -r ${tmpdir}/${ruleFile} -f ${dockerFile}
docker run -i --rm --privileged -v `pwd`:/root/ -v /var/run/docker.sock:/var/run/docker.sock projectatomic/dockerfile-lint dockerfile_lint -p -j -r ${tmpdir}/${ruleFile} -f ${dockerFile} > ${reportsDir}/dockerfile-lint-dockerfile.json
# Running this on the results image returns almost same results
# use -j to get json output
# Can get data from json with jq
# jq '.error.count' ${reportsDir}/dockerfile-lint-dockerfile.json
# jq '.warn.count' ${reportsDir}/dockerfile-lint-dockerfile.json
# jq '.info.count' ${reportsDir}/dockerfile-lint-dockerfile.json
# jq '.error.data[].message' ${reportsDir}/dockerfile-lint-dockerfile.json
jq --arg file ${dockerFile} -f ${tmpdir}/${parserFile} ${reportsDir}/dockerfile-lint-dockerfile.json > ${reportsDir}/dockerfile-lint-dockerfile.warnings
if [ ! -s ${reportsDir}/dockerfile-lint-dockerfile.warnings ]; then
  rm -f ${reportsDir}/dockerfile-lint-dockerfile.warnings
fi

###
### hadolint
###
# Big container: ~1.3 GB
#printf "=%.s" {1..3}
#echo -e "Running hadolint...\n"
# Requires absolute path to Dockerfile
#docker run -i --rm lukasmartinelli/hadolint hadolint -h
# No version available from app or image tags
#docker run -i --rm -v ${WORKSPACE}/${dockerFile}:/Dockerfile lukasmartinelli/hadolint hadolint /Dockerfile

###
### whale-linter
###
printf "=%.s" {1..3}
echo -e "Running whale-linter...\n"
docker run -i --rm jeromepin/whale-linter --version
docker run -i --rm -v ${WORKSPACE}/${dockerFile}:/Dockerfile jeromepin/whale-linter | tee ${reportsDir}/whale-linter.output
# Create transform script for Jenkins Warnings plugin
cat <<"WHALE" >${tmpdir}/parse-whale-linter.sh
#!/bin/bash
#
# Transform whale-linter output in single line output for Jenkins Warning plugin
#
input=$1
while read -r line || [[ -n "$line" ]]; do
  # Skip lines
  if [[ ! $(echo $line | grep ':' | wc -l) -gt 0 ]]; then
    continue
  fi
  # Remove all color codes first, will simplfy the rest of the regex matching
  # Mac
  #line=$(echo $line | sed -E 's/.\[[0-9]+m//g')
  # Linux
  line=$(echo $line | sed -r 's/.\[[0-9]+m//g')
  # Check for priority change and get
  if [[ $(echo $line | grep -E 'CRITICAL\s*:' | wc -l) -gt 0 ]]; then
    priority='CRITICAL'
    continue
  elif [[ $(echo "$line" | grep -E 'WARNING\s*:' | wc -l) -gt 0 ]]; then
    priority='WARNING'
    continue
  elif [[ $(echo "$line" | grep -E 'ENHANCEMENT\s*:' | wc -l) -gt 0 ]]; then
    priority='ENHANCEMENT'
    continue
  fi
  # Parse message lines
  #   21: [93mBadPractice : [0mThere is two consecutive 'RUN'. Consider chaining them with '\' and '&&'
  lineNumber=${line%%:*}
  lineNumber=$(echo $lineNumber | sed 's/^\s+//')
  if [ -z "$lineNumber" ]; then
    continue
  fi
  # if lineNumber is NOT a number, it is the category instead
  if [[ $lineNumber =~ ^[0-9]+$ ]]; then
    category=${line#*:}
    category=${category%%:*}
  else
    category=$lineNumber
    lineNumber=0
  fi
  msg=${line##*:}
  # Trim leading and trailing white space
  category=$(echo $category | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
  msg=$(echo $msg | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
  echo "${priority};${lineNumber};${category};${msg}"
done < "$input"
WHALE

chmod +x ${tmpdir}/parse-whale-linter.sh
${tmpdir}/parse-whale-linter.sh ${reportsDir}/whale-linter.output > ${reportsDir}/whale-linter.warnings

printf "=%.s" {1..30}
echo -e "\nFinished Dockerfile testing."
printf "=%.s" {1..30}
echo
