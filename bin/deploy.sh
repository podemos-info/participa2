#!/usr/bin/env bash

set -eo pipefail

if [ "${CIRCLE_BRANCH}" = "master" ]
then
  BRANCH=$CIRCLE_BRANCH bundle exec cap staging deploy | sed "s/$STAGING_SERVER_MASTER_HOST/***/g" | sed "s/$STAGING_SERVER_MASTER_PORT/***/g" | sed "s/$STAGING_SERVER_SLAVE_HOST/***/g" | sed "s/$STAGING_SERVER_SLAVE_PORT/***/g"
fi
