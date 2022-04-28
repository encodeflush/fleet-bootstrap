#!/bin/bash

helm template fleet -n fleet-system . -f values.yaml | kubectl -n fleet-system delete -f -
kubectl delete ns fleet-system
