# Sample app using jenkinsfile and kubernetes
- Golang
- Backend:  ./app
- frontend: ./app -frontend=true -backend-service=http://backend:8080 -port=8085
- Jenkinsfile
- Kubernetes deployments

## Update Jenkins version
helm upgrade  -f values.yaml <RELEASE-NAME> stable/jenkins

## K8s deploy applications

```
$ kubectl create namespace production
$ kubectl create namespace stage
$ kubectl --namespace=production apply -f k8s/production
$ kubectl --namespace=production apply -f k8s/canary
$ kubectl --namespace=production apply -f k8s/services
```