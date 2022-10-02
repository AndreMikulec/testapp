#!/usr/bin/env bash

# Release Assets
# https://cirrus-ci.org/examples/#release-assets
#
# some default environment variables are pre-defined
#   CIRRUS_TAG	
#     Tag name if current build was triggered by a new tag. For example v1.0
#   CIRRUS_RELEASE
#     GitHub Release id if current tag was created for a release. Handy for uploading release assets.
# https://cirrus-ci.org/guide/writing-tasks/
#
# Secured Variables (per repository) 
#   https://cirrus-ci.org/guide/writing-tasks/#encrypted-variables
#   FROM
#     https://cirrus-ci.com/github/AndreMikulec/REPOSITORY -> Settings


if [[ "$CIRRUS_RELEASE" == "" ]]; then
  echo "Not a release. No need to deploy!"
  exit 0
fi

if [[ "$GITHUB_TOKEN" == "" ]]; then
  echo "Please provide GitHub access token via GITHUB_TOKEN environment variable!"
  exit 1
fi

#
# binary file
# 
file_content_type="application/octet-stream"
files_to_upload=(
  # relative paths of assets to upload
  # I SHOULD NOT HARDCODE THIS
  ${CIRRUS_REPO_NAME}_Linux_ARM64_Debug.zip
)

for fpath in $files_to_upload
do
  echo "Uploading $fpath..."
  name=$(basename "$fpath")
  url_to_upload="https://uploads.github.com/repos/$CIRRUS_REPO_FULL_NAME/releases/$CIRRUS_RELEASE/assets?name=$name"
  curl -X POST \
    --data-binary @$fpath \
    --header "Authorization: token $GITHUB_TOKEN" \
    --header "Content-Type: $file_content_type" \
    $url_to_upload
done
