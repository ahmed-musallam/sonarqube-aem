#!/usr/bin/env bash

docker ps | grep sonarqube-aem | awk '{print $1}' | xargs docker kill