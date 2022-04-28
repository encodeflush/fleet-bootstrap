#!/bin/bash

kubectl create ns fleet-system
helm template fleet -n fleet-system . -f values.yaml | kubectl -n fleet-system apply -f -
