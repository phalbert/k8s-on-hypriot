
http://prometheus:8080 
http://loki:3100

if you need to update the prometheus config, it can be reloaded by making an api call to the prometheus server. curl -XPOST http://<prom-service>:<prom-port>/-/reload
