# Kubernetes on Hypriot

Build a [Kubernetes](https://kubernetes.io/) ([k3s](https://github.com/rancher/k3s)) cluster with RPis and utilize [GitOps](https://www.weave.works/technologies/gitops/) for managing cluster state.

Thanks to https://gist.github.com/elafargue/a822458ab1fe7849eff0a47bb512546f and https://github.com/onedr0p/homelab-gitops

## Pre-reqs:

* This was done using a cluster of 4 x RPi 4 4GB
* All Pi's are connected via a local ethernet switch on a 10.0.0.0/24 LAN
* The master node connects to the outside world on WiFi, and provides NAT for the the rest of the cluster.

## Directory layout description

```bash
.
│   # Flux will scan and deploy from this directory
├── ./deployments
│   # Initial setup of the cluster
├── ./setup
│   │   # Flash the SDCard with HypriotOS
│   └─ ./nodes
│   # Builds for ARM devices
└── ./docker
```

## Network topology


|IP|Function|
|---|---|
|192.168.1.1|Router|
|192.168.1.18|Master Network IP|
|10.0.0.0/24|K3S cluster CIDR|
|10.0.0.1|k3s master (master)|
|10.0.0.2|k3s worker (node-1)|
|10.0.0.3|k3s worker (node-2)|
|10.0.0.4|k3s worker (node-3)|
