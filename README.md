# app-jenkinsfile-k8s
Sample app using jenkinsfile and kubernetes

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