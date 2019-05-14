#!/bin/sh

kubectl label node master node-role.kubernetes.io/edge=""
kubectl label node node-1 blinktShow=true
kubectl label node node-2 blinktShow=true
kubectl label node node-3 blinktShow=true
kubectl label node master blinktShow=true
kubectl label node master blinktImage=nodes
kubectl label node node-1 blinktImage=pods
kubectl label node node-2 blinktImage=pods
kubectl label node node-3 blinktImage=pods