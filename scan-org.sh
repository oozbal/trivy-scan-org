#!/bin/bash
# set username, password, and organization
UNAME=""
UPASS=""   #user password or pat (dckr_****).
ORG=""

SCAN_DATE=$(date '+%F')
OUTPUT_FOLDER="scan-results-${SCAN_DATE}"
mkdir ${OUTPUT_FOLDER}
LOG_FILE="./${OUTPUT_FOLDER}/log-${SCAN_DATE}.txt"



# -------

set -e
echo

# get token
echo "Retrieving token ..."
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)

# Retrieve repositories under organization
echo "Retrieving repository list ..."
REPO_LIST=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${ORG}/?page_size=100 | jq -r '.results|.[]|.name')

# output images & tags
echo
echo "Images and tags for organization: ${ORG}"
echo
for i in ${REPO_LIST}
do
  # retrieve last updated image tag of each repository.
  IMAGE_TAGS=$(curl -s -H "Authorization: JWT ${TOKEN}" https://hub.docker.com/v2/repositories/${ORG}/${i}/tags/?page_size=100 | jq -r '.results[] | [ .name , .tag_last_pushed ] | @tsv' | sed -E 's/(.*:[0-9]{2})\..*Z/\1/g' |sort -t$'\t' -k2 -nr |awk '{print $1}' |head -n 1)
  for j in ${IMAGE_TAGS}
  do
    echo  "${i}	jitterbitdev/${i}:${j}\c" >>$LOG_FILE
    trivy image --format template --template @html.tpl -o ${OUTPUT_FOLDER}/${i}-trivy-scan.html --ignore-unfixed ${ORG}/${i}:${j} && echo " completed" >>$LOG_FILE || echo " error" >>$LOG_FILE ; continue
  done
#  echo
done

