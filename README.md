# app-jenkinsfile-k8s
Sample app using jenkinsfile and kubernetes

## Testing locally
http://localhost:8080/
http://localhost:8080/healthz
http://localhost:8080/version

## Update Jenkins version
helm upgrade  -f values.yaml <RELEASE-NAME> stable/jenkins