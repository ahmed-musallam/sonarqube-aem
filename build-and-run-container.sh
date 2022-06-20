#!/usr/bin/env bash

docker build --tag "sonarqube-aem" -f "Dockerfile" .
docker run --publish 9000:9000  sonarqube-aem
