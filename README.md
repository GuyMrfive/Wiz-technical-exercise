# Wiz-technical-exercise

# Deployments Guide
1. Run Infrastructure Pipeline and verify rg-wiz-exercise existence 
3. SSH into the Vm and verfiy MongoDB Deployment thorough Cloud init script, copy the init tasky script and run it. after that add the DB Permission for the azureuser
2. Run Deploy Pipeline, verify container Image through get service ingress
3. 

# Important Commands

1. Activate port Forwading
`kubectl port-forward svc/tasky 8080:80`
2. ssh into vm (first find the public IP)
`ssh -i ~/.ssh/wiz-exercise azureuser@<PUBLIC_IP`
3. Connect to AKS
```bash
az aks get-credentials \
  --resource-group rg-wiz-exercise \
  --name aks-wiz-exercise \
  --admin \
  --overwrite-existing
```
4. get logs from tasky deployment
```bash
kubectl logs deployment/tasky --tail=100
```
```bash
kubectl rollout restart deployment/tasky
kubectl rollout status deployment/tasky
```
5. Connect to mongoDB

`sudo cloud-init status --wait`

Check the MongoDB service:

```bash
sudo systemctl status mongod --no-pager
```
Verify the installed version:

```bash
mongod --version
```

Copy the init script

```bash
scp -i ~/.ssh/wiz-exercise \
  scripts/mongodb/init-tasky.sh \
  azureuser@<VM_PUBLIC_IP>:~/
```

Add the New Connection String: 

```bash
kubectl create secret generic tasky-secrets \
  --from-literal=MONGODB_URI='mongodb://azureuser:YOUR_PASSWORD@10.0.2.4:27017/go-mongodb?authSource=tasky' \
  --dry-run=client -o yaml | kubectl apply -f -
```
6. Authenticate to MongoDB

Connect using the application database account:

```bash
mongo --host 127.0.0.1 \
  --authenticationDatabase tasky \
  -u azureuser \
  -p
```

Enter the MongoDB password

7. Inspect application data

```bash
use tasky

db.grantRolesToUser("azureuser", [
  { role: "readWrite", db: "go-mongodb" }
])
```

```bash
db.getUser("azureuser")
```


8. get the public ingress

```bash
kubectl get svc -n ingress-nginx
kubectl get pods -n ingress-nginx
```

Inspect the ingress configuration:

```bash
kubectl describe ingress tasky
```

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