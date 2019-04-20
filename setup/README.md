##### /etc/network/interfaces.d/eth0

```
allow-hotplug eth0
iface eth0 inet static
	address 10.0.0.1
	netmask 255.255.255.0
	network 10.0.0.0
	broadcast 10.0.0.255
	gateway 10.0.0.1
```

##### On nodes /etc/dhcpcd.conf

```
denyinterfaces cni*,docker*,wlan*,flannel*,veth*
```


##### /etc/dhcp/dhcpd.conf
```
option domain-name "cluster.home";
option domain-name-servers 8.8.8.8, 8.8.4.4;

default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet 10.0.0.0 netmask 255.255.255.0 {
	range 10.0.0.1 10.0.0.10;
	option subnet-mask 255.255.255.0;
	option broadcast-address 10.0.0.255;
	option routers 10.0.0.1;
}

host node-1 {
	hardware ethernet b8:27:eb:a7:c2:22;
	fixed-address 10.0.0.2;
}

host node-2 {
	hardware ethernet b8:27:eb:af:e4:89;
	fixed-address 10.0.0.3;
}

host node-3 {
	hardware ethernet b8:27:eb:8b:05:83;
	fixed-address 10.0.0.4;
}
```

##### /etc/cloud/templates/hosts.debian.tmpl

```
# Kubernetes cluster
10.0.0.1 mater
10.0.0.2 node-1
10.0.0.3 node-2
10.0.0.4 node-3
```

###
```bash
sudo apt-get install isc-dhcp-server dnsmasq nfs-server 
sudo systemctl disable dhcpcd.service
sudo systemctl stop dhcpcd.service
```
### nodes

```
sudo apt-get install rfkill  
```


then, edit `/etc/default/dnsmasq` to add the `-2` flag to the default options (disable DHCP and TFTP): uncomment the `DNSMASQ` line and make sure it reads:

```
DNSMASQ_OPT='-2'
```

`ENABLED` should be at 1.

Last, restart dnsmasq:

```
/etc/init.d/dnsmasq restart
```

### Setup NAT

You want the master node to be the gateway for the rest of the cluster, and do the NAT for outside world access. You can simply create an init script that will do this (see corten_enable_nat below).

You can enable the script as follows

```
sudo chmod +x /etc/init.d/enable_nat
sudo update-rc.d enable_nat defaults
```

##### /etc/init.d/enable_nat
```
#! /bin/sh

### BEGIN INIT INFO
# Provides:          routing
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:
# X-Start-Before:    rmnologin
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Add masquerading for other nodes in the cluster
# Description:  Add masquerading for other nodes in the cluster
### END INIT INFO

. /lib/lsb/init-functions

N=/etc/init.d/enable_nat

set -e

case "$1" in
  start)
	iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
	iptables -A FORWARD -i wlan -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
	iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
    ;;
  stop|reload|restart|force-reload|status)
    ;;
  *)
    echo "Usage: $N {start|stop|restart|force-reload|status}" >&2
    exit 1
    ;;
esac

exit 0
```

Also, edit `/etc/sysctl.conf` to enable IP routing: uncomment the net.ipv2.ip_forward=1 line if it is commented

```
net.ipv4.ip_forward=1
```

###

```
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - 
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.0.0.1
```

###
```
$ sudo mkdir /media/usb
$ sudo chown -R pirate:pirate /media/usb
$ sudo mount /dev/sda1 /media/usb -o uid=pirate,gid=pirate
```

##### /etc/fstab

```
UUID=bd14fe02-663c-3fb3-86a5-60418c5364d3 /media/usb ext4 auto,nofail,noatime,users,rw,uid=pirate,gid=pirate 0 0
```

##### /etc/exports
```
/media/usb 10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)
```

```
$ sudo update-rc.d rpcbind enable && sudo update-rc.d nfs-common enable
$ sudo reboot
```

####nodes
```
$ sudo apt-get install nfs-common
```