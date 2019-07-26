#!/bin/bash

sed -i 's/http_version: $/http_version:/' spec/fixtures/vcr/*.yml
