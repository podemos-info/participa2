#!/bin/bash

set -eou pipefail

curl --silent \
     --show-error \
     --location \
     --fail \
     --retry 3 \
     --output /tmp/geckodriver_linux64.tar.gz \
     https://github.com/mozilla/geckodriver/releases/download/v0.20.1/geckodriver-v0.20.1-linux64.tar.gz

tar xvzf /tmp/geckodriver_linux64.tar.gz -C /usr/local/bin

rm /tmp/geckodriver_linux64.tar.gz
