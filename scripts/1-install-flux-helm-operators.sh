helm repo add fluxcd https://charts.fluxcd.io
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/flux-helm-release-crd.yaml

kubectl apply -f ./namespaces/flux-namespace.yaml

helm upgrade -i flux fluxcd/flux --wait \
--namespace fluxcd \
--set git.url=git@github.com:cbellee/colourserver-flux-cd \
--set git.path="clusters/dev" \
--set git.label=dev \
--set additionalArgs={--sync-garbage-collection} \
--set git-poll-interval=1m \
--set sync-interval=1m \
--set sync-timeout=30s

helm upgrade -i helm-operator fluxcd/helm-operator --wait \
--namespace fluxcd \
--set git.ssh.secretName=flux-git-deploy \
--set helm.versions=v3

export FLUX_FORWARD_NAMESPACE=fluxcd

fluxctl identity
