# Wiz-technical-exercise

# Deployments Guide
1. Run Infrastructure Pipeline and verify rg-wiz-exercise existence 
3. SSH into the Vm and verfiy MongoDB Deployment thorough Cloud init script, copy the init tasky script and run it. after that add the DB Permission for the azureuser
2. Run Deploy Pipeline, verify container Image through get service ingress
3. 

# Important Commands

## K8s Commands

#### Activate port Forwading
`kubectl port-forward svc/tasky 8080:80`

#### Download Kubeconfig, set Context
```
az aks get-credentials \
  --resource-group rg-wiz-exercise \
  --name aks-wiz-exercise \
  --admin \
  --overwrite-existing
```

#### get all logs for deployment

```bash
kubectl logs deployment/tasky --tail=100
```

#### Add the New Connection String: 

```bash
kubectl create secret generic tasky-secrets \
  --from-literal=MONGODB_URI='mongodb://azureuser:YOUR_PASSWORD@10.0.2.4:27017/go-mongodb?authSource=tasky' \
  --dry-run=client -o yaml | kubectl apply -f -
```

## DB Commands

#### Status of the Cloud-init script

`sudo cloud-init status --wait`

#### Check the MongoDB service:

```bash
sudo systemctl status mongod --no-pager
```
#### get MongoDb Version

```bash
mongod --version
```

#### Copy the init script from scripts directory into VM

```bash
scp -i ~/.ssh/wiz-exercise \
  scripts/mongodb/init-tasky.sh \
  azureuser@<VM_PUBLIC_IP>:~/
```
```bash
chmod +x ~/init-tasky.sh
./init-tasky.sh
```
#### Connect to MongoDB with admin Credentials
```bash
mongo --authenticationDatabase admin -u mongoAdmin -p
```

#### Connect using the Application Account
```bash
mongo --host 127.0.0.1 \
  --authenticationDatabase tasky \
  -u azureuser \
  -p
```

#### Grant readwrite permissions on DB 
```bash
use tasky

db.grantRolesToUser("azureuser", [
  { role: "readWrite", db: "go-mongodb" }
])
```

```bash
db.getUser("azureuser")
```

## Old Commands

```bash
kubectl rollout restart deployment/tasky
kubectl rollout status deployment/tasky
```

```bash
kubectl describe ingress tasky
```

```bash
kubectl exec deployment/tasky -- cat /app/wizexercise.txt
```




