#!/bin/bash

if [ -z "${ASSET_NAME}" -o -z "${AWS_URL}" -o -z "${ITERATION}" ]; then
  echo "ASSET_NAME, AWS_URL or ITERATION variable was not passed to container. Exiting..."
  exit 1
fi

START=1
while [ ${START} -le  ${ITERATION} ] ; do
  curl --silent --show-error --fail -X POST ${AWS_URL} -d " \
  { \
  \"chainname\": \"${ASSET_NAME}\", \
  \"height\": \"${START}\" \
  } \
  " &
  START=$((START+1))
  echo "Request sent..."
  sleep 0.01
done
