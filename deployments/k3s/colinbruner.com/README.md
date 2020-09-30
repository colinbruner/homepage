# Homepage
k3s yaml files for deploying colinbruner.com homepage on a raspberry pi cluster. 

## Deployment
To future me, who may (probably may) or may not need this file.

```bash
alias k=kubectl
```

1. Create the homepage namespace.
2. Create the service endpoint on all nodes.
3. Create the nginx proxy deployment.

```bash
kubectl apply -f homepage.json
kubectl apply -f service.yaml
kubectl apply -f deploy.yaml
```

## Post
Switch context to homepage and view creating pods and service

``` bash
kubectl config set-context --current --namespace=homepage
kubectl get pod
kubectl get svc
```

