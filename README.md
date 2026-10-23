# Wiz-technical-exercise

# Deployments Steps
1. Run Infrastructure Pipeline
2. Run Deploy Pipeline
3. create role assignement with ACR Pull for kubelet identity

# Commands

1. Activate port Forwading
`kubectl port-forward svc/tasky 8080:80`
2. ssh into vm (first find the public IP)
`ssh -i ~/.ssh/wiz-exercise azureuser@20.85.222.158`
3. Connect to AKS

```bash
az aks get-credentials \
  --resource-group rg-wiz-exercise \
  --name aks-wiz-exercise \
  --admin \
  --overwrite-existing
```

```bash
kubectl logs deployment/tasky --tail=100
```

Check the application deployment:

```bash
kubectl describe deployment tasky
```

```bash
kubectl rollout restart deployment/tasky
kubectl rollout status deployment/tasky
```

Refresh the frontend and log in again. The task should still exist because it is stored in MongoDB rather than in the Kubernetes Pod.

4. Connect to mongoDB

SSH into the MongoDB virtual machine:

```bash
ssh -i ~/.ssh/wiz-exercise \
  azureuser@PRIVATEIP
```

Check the MongoDB service:

```bash
sudo systemctl status mongod --no-pager
```

Verify the installed version:

```bash
mongod --version
```

5. Authenticate to MongoDB

Connect using the application database account:

```bash
mongo --host 127.0.0.1 \
  --authenticationDatabase tasky \
  -u azureuser \
  -p
```

Enter the MongoDB password when prompted.

6. Inspect application data

Inside the MongoDB shell:

```javascript
show dbs
use go-mongodb
show collections
```

Inspect stored tasks (confirm the collection name first):

```javascript
db.task.find().limit(10).pretty()
```

Inspect application users without displaying their password fields:

```javascript
db.user.find({}, { password: 0 }).limit(5).pretty()
```

Count stored documents:

```javascript
db.task.countDocuments({})
```

### 7. Exit safely

Exit the MongoDB shell:

```javascript
exit
```

Disconnect from the VM:

```bash
exit
```

Both MongoDB and the VM continue running.

### 8. Inspect the public ingress

```bash
kubectl get ingress tasky
kubectl get svc -n ingress-nginx
kubectl get pods -n ingress-nginx
```

Inspect the ingress configuration:

```bash
kubectl describe ingress tasky
```

9. Inspect Azure resources

```bash
az resource list \
  --resource-group rg-wiz-exercise \
  --output table
```

Retrieve the MongoDB VM's private IP:

```bash
az vm show \
  --resource-group rg-wiz-exercise \
  --name vm-wiz-mongodb \
  --show-details \
  --query privateIps \
  --output tsv
```
```bash
kubectl exec deployment/tasky -- cat /app/wizexercise.txt
```



### 10. Demo talking points

- **Infrastructure as Code:** Azure resources are provisioned using modular Bicep templates.
- **CI/CD:** GitHub Actions builds and pushes the Tasky container image to Azure Container Registry and deploys it to AKS.
- **Networking:** AKS connects to MongoDB through private Azure networking.
- **Kubernetes:** Tasky runs as a Deployment behind a ClusterIP Service and NGINX Ingress.
- **Persistence:** Tasks survive application Pod restarts because data is stored externally in MongoDB.
- **Security assessment:** The environment intentionally contains security weaknesses for detection and demonstration with Wiz, including outdated MongoDB and excessive Kubernetes RBAC privileges.
- **Backups:** MongoDB backups to Azure Blob Storage should be demonstrated after backup automation is configured and verified.

**Security note:** Do not store passwords, connection-string credentials, or SSH private keys in this README. Public IP addresses may change if resources are recreated.