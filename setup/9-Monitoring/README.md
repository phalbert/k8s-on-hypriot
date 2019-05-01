
http://prometheus:8080 
http://loki:3100

if you need to update the prometheus config, it can be reloaded by making an api call to the prometheus server. curl -XPOST http://<prom-service>:<prom-port>/-/reload

Please update 00-alertmanager-configmap.yaml to reflect correct api_url for Slack and VictorOps. You can additionally add more receievers. Ref: https://prometheus.io/docs/alerting/configuration/