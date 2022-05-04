#!/bin/bash

set -xe 

export KUBECONFIG="$HOME/.kube/central"
kubectl apply -f ./configs/gcp-clusters-ns.yaml
kubectl apply -f ./configs/cluster-registration-token.yaml
kubectl -n gcp-clusters get secret demo-token -o 'jsonpath={.data.values}' | base64 --decode > ./configs/values.yaml
kubectl config view -o json --raw  | jq -r '.clusters[].cluster["certificate-authority-data"]' | base64 -d > ./configs/ca.pem 
API_SERVER_URL=$(kubectl config view -o json --raw  | jq -r '.clusters[].cluster["server"]')
API_SERVER_CA="./configs/ca.pem"

export KUBECONFIG="$HOME/.kube/downstream"
CLUSTER_LABELS="--set-string labels.demo=true --set-string labels.env=gcp"   
kubectl get no 
helm -n fleet-system upgrade --install --create-namespace --wait \
    ${CLUSTER_LABELS} \
    --set apiServerURL=$API_SERVER_URL \
    --set apiServerCA=$API_SERVER_CA \
    --values ./configs/values.yaml\
    fleet-agent https://github.com/rancher/fleet/releases/download/v0.3.9/fleet-agent-0.3.9.tgz
