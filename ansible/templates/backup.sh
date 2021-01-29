AZURE_RESOURCE_GROUP=$(az aks show -n $1 -g $2 --query "nodeResourceGroup" -o tsv)    # $1: cluster name   $2: current resource group
AZURE_SUBSCRIPTION_ID=$4 #$(az account list --query '[?isDefault].id' -o tsv)
AZURE_TENANT_ID=$5 #$(az account list --query '[?isDefault].tenantId' -o tsv)
AZURE_CLIENT_SECRET=$7 #$(az ad sp create-for-rbac --name "$1-velero" --role "Contributor" --query 'password' -o tsv)
AZURE_CLIENT_ID=$6  #$(az ad sp list --display-name "$1-velero" --query '[0].appId' -o tsv)
BACKUP_RESOURCE_GROUP=$3      # $3: resource group to store backup
BACKUP_STORAGE_ACCOUNT_NAME=velero$(uuidgen | cut -d '-' -f5 | tr '[A-Z]' '[a-z]')
STORAGE_CONTAINER_NAME=velero

cat << EOF  > ./credentials-velero
AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}
AZURE_TENANT_ID=${AZURE_TENANT_ID}
AZURE_CLIENT_ID=${AZURE_CLIENT_ID}
AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET}
AZURE_RESOURCE_GROUP=${AZURE_RESOURCE_GROUP}     # <- This changed to ${TARGET_AKS_RESOURCE_GROUP} for restore
AZURE_CLOUD_NAME=AzureUSGovernmentCloud
EOF

# Create Azure Storage Account
az storage account create \
  --name $BACKUP_STORAGE_ACCOUNT_NAME \
  --resource-group $BACKUP_RESOURCE_GROUP \
  --sku Standard_GRS \
  --encryption-services blob \
  --https-only true \
  --kind BlobStorage \
  --access-tier Hot
  
 # Create Blob Container
 az storage container create \
   --name $STORAGE_CONTAINER_NAME \
   --public-access off \
   --account-name $BACKUP_STORAGE_ACCOUNT_NAME

#Please follow below steps to install Velero in Ubuntu :

wget https://github.com/vmware-tanzu/velero/releases/download/v1.5.2/velero-v1.5.2-linux-amd64.tar.gz
tar -zxvf velero-v1.5.2-linux-amd64.tar.gz
sudo mv velero-v1.5.2-linux-amd64/velero /usr/local/bin/

#Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# ./backup.sh now-test-aks now-test-resgp final-dev-resgp
kubectl create ns velero
kubectl create secret generic velero-credentials -n velero --from-literal="cloud=$(cat ./credentials-velero)"

#add the VMware Tanzu Helm repo.
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
#install the helm chart.
helm install velero vmware-tanzu/velero --namespace velero --version 2.13.2 \
--set "initContainers[0].image=velero/velero-plugin-for-microsoft-azure:v1.1.0" \
--set "initContainers[0].imagePullPolicy=IfNotPresent" \
--set "initContainers[0].volumeMounts[0].mountPath=/target" \
--set "initContainers[0].volumeMounts[0].name=plugins" \
--set "initContainers[0].name=velero-plugin-for-azure" \
--set credentials.existingSecret='velero-credentials' \
--set configuration.provider='azure' \
--set configuration.backupStorageLocation.bucket=$STORAGE_CONTAINER_NAME \
--set configuration.backupStorageLocation.config.resourceGroup=$BACKUP_RESOURCE_GROUP \
--set configuration.backupStorageLocation.config.storageAccount=$BACKUP_STORAGE_ACCOUNT_NAME \
--set configuration.backupStorageLocation.config.subscriptionId=$AZURE_SUBSCRIPTION_ID \
--set configuration.volumeSnapshotLocation.name='usgovvirginia' \
--set configuration.volumeSnapshotLocation.config.resourceGroup=$BACKUP_RESOURCE_GROUP \
--set configuration.volumeSnapshotLocation.config.subscriptionId=$AZURE_SUBSCRIPTION_ID

#see Velero’s pods come up.
kubectl get pods -n velero

#Testing the backup
# velero backup create my-backup

# velero backup logs my-backup

# # #Setting up the schedule
# velero schedule create every-day-at-7 --schedule "0 7 * * *"