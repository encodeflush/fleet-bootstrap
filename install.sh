#!/bin/bash

set -xe

mkdir ./configs
export KUBECONFIG="$HOME/.kube/central"
kubectl config view -o json --raw  | jq -r '.clusters[].cluster["certificate-authority-data"]' | base64 -d > ./configs/ca.pem 
API_SERVER_URL=$(kubectl config view -o json --raw  | jq -r '.clusters[].cluster["server"]')
API_SERVER_CA="./configs/ca.pem"
echo $API_SERVER_URL
echo $API_SERVER_CA
kubectl get no -o wide
kubectl apply -f ./configs/fleet-ns.yaml
helm template fleet \
  --set apiServerURL=$API_SERVER_URL \
  --set apiServerCA=$API_SERVER_CA \
  -n fleet-system . \
  -f values.yaml | kubectl -n fleet-system apply -f -
