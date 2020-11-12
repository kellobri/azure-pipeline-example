#!/usr/bin/env bash
#
# Update the vanity URL for the current content item, 
# forcefully remove it from any other.
#
# Run this script from the content root directory.
#

set -e

if [ -z "${CONNECT_SERVER}" ] ; then
    echo "The CONNECT_SERVER environment variable is not defined. It defines"
    echo "the base URL of your RStudio Connect instance."
    echo 
    echo "    export CONNECT_SERVER='http://connect.company.com/'"
    exit 1
fi

if [[ "${CONNECT_SERVER}" != */ ]] ; then
    echo "The CONNECT_SERVER environment variable must end in a trailing slash. It"
    echo "defines the base URL of your RStudio Connect instance."
    echo 
    echo "    export CONNECT_SERVER='http://connect.company.com/'"
    exit 1
fi

if [ -z "${CONNECT_API_KEY}" ] ; then
    echo "The CONNECT_API_KEY environment variable is not defined. It must contain"
    echo "an API key owned by a 'publisher' account in your RStudio Connect instance."
    echo
    echo "    export CONNECT_API_KEY='jIsDWwtuWWsRAwu0XoYpbyok2rlXfRWa'"
    exit 1
fi

if [ -z "${CONTENT}" ] ; then
    echo "The CONTENT (GUID) environment variable is not defined.
    echo
    echo "    export CONTENT='9f790f22-62b3-49d9-b957-3ae86d3eb823'"
    exit 1
fi

if [ $# -eq 0 ] ; then
    echo "usage: $0 <content-title>"
    exit 1
fi

DATA='{
  "path": "'${VANITY_NAME}'"
  "force": "true"
}'

# Build the JSON to create a vanity force update request
DATA=$(jq --arg path "${VANITY_NAME}" \
   --arg force  "true" \
   '. | .["path"]=$path | .["force"]=$force' \
   <<<'{}')

RESULT=$(curl --silent --show-error -L --max-redirs 0 --fail -X PUT \
    -H "Authorization: Key ${CONNECT_API_KEY}" \
    --data-binary "${DATA}" \
    "${CONNECT_SERVER}__api__/v1/content/${CONTENT}/vanity")
RESPONSE=(echo "$RESULT" | jq -r .path)

echo "Vanity URL Update Complete."