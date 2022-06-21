# sonarqube-aem

This is a docker image that is identical to the official [sonarqube docker image](https://github.com/SonarSource/docker-sonarqube/blob/master/8/community/Dockerfile) with an added script to install [AEM-Rules-for-SonarQube](https://github.com/Cognifide/AEM-Rules-for-SonarQube) extension.

## Running

Latest from Docker Hub:

```sh
docker run --rm -p 9000:9000 ahmedmusallam/sonarqube-aem:latest
```

From Source:

Clone the repo and run the `build-and-run-container.sh` script. Or open it and run the commands manually. Sonar will run on port 9000.

## Custom Quality Gates

Take a look at `quality.sh` in source code and adjust it to your needs.

By default, that script will create a new `aem-gate` Gate and set the following Conditions:

- Code Coverage - 75% required
- Code Smells - A require
- Maintainability Rating - A required
- Reliability Rating - A required
- Security Rating - A required

