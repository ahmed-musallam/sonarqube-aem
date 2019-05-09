#!/usr/bin/env bash

docker build -t "sonarqube-aem" -f "Dockerfile" .
docker run -p 9000:9000 sonarqube-aem
