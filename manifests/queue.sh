#!/bin/sh

curl -X PUT http://kuard.cluster.local/memq/server/queues/keygen

for i in work-item-{0..99}; do
    curl -X POST http://kuard.cluster.local/memq/server/queues/keygen/enqueue -d "$i"
done

curl http://kuard.cluster.local/memq/server/stats