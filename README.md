# Wiz-technical-exercise

# Deployments Steps
1. Run Infrastructure Pipeline
2. Run Deploy Pipeline
3. create role assignement with ACR Pull for kubelet identity

# Commands

1. Activate port Forwading
`kubectl port-forward svc/tasky 8080:80`