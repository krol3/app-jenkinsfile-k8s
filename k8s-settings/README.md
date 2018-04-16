# Settings Kubernetes cluster

### Settings authentication in cluster kubernetes

```
kubectl create -f admin-sa.yaml
serviceaccount "admin-user" created

kubectl create -f admin-crb.yaml
clusterrolebinding.rbac.authorization.k8s.io "admin-user" created
```

### Get the token to login the dashboard

```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```

## Init Helm and authentication in kubernetes

```
kubectl create -f tiller-rbac.yaml

kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

helm init --service-account=tiller
```

https://github.com/kubernetes/helm/issues/3055

## Install Jenkins with Helm

```
helm install -f jenkins-values.yaml stable/jenkins
```

### Upgrade Jenkins version

```
helm upgrade  -f jenkins-values.yaml <RELEASE-NAME> stable/jenkins
```

#### Jenkins password

```
printf $(kubectl get secret --namespace <INSTALLED> <SERVICE> -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
```

### Authorize Jenkins in Service Account

SA system:serviceaccount:default:default

```
kubectl create -f default-crb.yaml
```



