# assumes ACR Admin Account is enabled

ACR_NAME=acrd8f374
ACR_FULL_NAME="${ACR_NAME}.azurecr.io"

ACR_UNAME=$(az acr credential show -n $ACR_NAME --query="username" -o tsv)
ACR_PASSWD=$(az acr credential show -n $ACR_NAME --query="passwords[0].value" -o tsv)

kubectl create secret docker-registry acr-secret -n fluxcd \
  --docker-server=$ACR_FULL_NAME \
  --docker-username=$ACR_UNAME \
  --docker-password=$ACR_PASSWD \
  --docker-email=ignorethis@email.com

