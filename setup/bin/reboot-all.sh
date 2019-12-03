#!/bin/bash

set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
source "$REPO_ROOT/setup/nodes.env"

# raspberry pi4 worker nodes
for node in $K3S_WORKERS_RPI; do
    message "Rebooting $node"
    ssh -o "StrictHostKeyChecking=no" $node "sudo reboot"
done

# k3s master node
message "Rebooting $K3S_MASTER"
ssh -o "StrictHostKeyChecking=no" $K3S_MASTER "sudo reboot"

message "All done - everything is rebooting!"