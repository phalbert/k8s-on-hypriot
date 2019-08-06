# Kubernetes on Hypriot

These are instructions for standing up a Kubernetes cluster with Raspberry Pi.

Thanks to https://gist.github.com/elafargue/a822458ab1fe7849eff0a47bb512546f

## Pre-reqs:

* This was done using a cluster of 4 RPi 3 B+
* All Pi's are connected via a local ethernet switch on a 10.0.0.0/24 LAN
* The master node connects to the outside world on WiFi, and provides NAT for the the rest of the cluster.

## Flash Hypriot to a fresh SD card.

```bash
curl -O https://raw.githubusercontent.com/hypriot/flash/2.2.0/flash
chmod +x flash
sudo mv flash /usr/local/bin/flash

flash -u nodes/master-user-data https://github.com/hypriot/image-builder-rpi/releases/download/v1.10.0/hypriotos-rpi-v1.10.0.img.zip
```

Repeat for "node1" to "node3" using the ```nodeX-user-data``` file for each node.

## Master node config

### Generate the master's SSH key

Login to the master node, and run `ssh-keygen` to initialize your SSH key.

### Set a static IP address on master

Login to 'master' and edit `/etc/network/interfaces.d/eth0`

```
allow-hotplug eth0
iface eth0 inet static
	address 10.0.0.1
	netmask 255.255.255.0
	network 10.0.0.0
	broadcast 10.0.0.255
	gateway 10.0.0.1
```

Disable `eth0` in `/etc/network/interfaces.d/50-cloud-init.cfg`

### On master and all nodes

Edit `/etc/cloud/templates/hosts.debian.tmpl`

```
# Kubernetes cluster
10.0.0.1 master
10.0.0.2 node-1
10.0.0.3 node-2
10.0.0.4 node-3
```

### On master

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y isc-dhcp-server nfs-server rfkill
sudo apt autoremove -y
sudo systemctl disable dhcpcd.service
sudo systemctl stop dhcpcd.service
```

Edit `/etc/dhcp/dhcpd.conf`

```
option domain-name "cluster.local";
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

##### On master and all nodes /etc/dhcpcd.conf

```
denyinterfaces cni*,docker*,wlan*,flannel*,veth*
```

### Setup NAT

You want the master node to be the gateway for the rest of the cluster, and do the NAT for outside world access.

Create the file `/etc/init.d/enable_nat`

```bash
#!/bin/sh

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

Enable the script as follows

```bash
sudo chmod +x /etc/init.d/enable_nat
sudo update-rc.d enable_nat defaults
```

Edit `/etc/sysctl.conf` to enable IP routing: uncomment the `net.ipv4.ip_forward=1` line if it is commented out


### On master

```bash
sudo lsblk -o UUID,NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL,MODEL
sudo mkdir /media/usb
sudo chown -R pirate:pirate /media/usb
#sudo mount /dev/sda1 /media/usb -o uid=pirate,gid=pirate
```

Edit `/etc/fstab`

```
#UUID=.... /media/usb ext4 auto,nofail,noatime,users,rw,uid=pirate,gid=pirate 0 0
UUID=.... /media/usb ext4 auto,nofail,noatime,users,rw 0 0
```

Edit `/etc/exports`

```
/media/usb 10.0.0.0/24(rw,sync,no_subtree_check,no_root_squash)
```

```bash
sudo exportfs -a
sudo update-rc.d rpcbind enable && sudo update-rc.d nfs-common enable
sudo reboot
```

### On nodes

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y rfkill nfs-common
sudo apt autoremove -y
sudo update-rc.d nfs-common enable
```

### On master and all nodes

```bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt upgrade -y
sudo apt install -y docker-ce=18.06.3~ce~3-0~raspbian kubelet kubeadm kubectl kubernetes-cni --allow-downgrades
sudo apt-mark hold docker-ce
```

### On master

```bash
sudo kubeadm config images pull
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.0.0.1
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### On nodes

```bash
sudo kubeadm config images pull
sudo kubeadm join 10.0.0.1:6443 --token <token> --discovery-token-ca-cert-hash sha256:1c06faa186e7f85...
```

#### To remove everything
```bash
sudo apt-get -y remove --purge kubeadm kubectl kubelet && sudo apt-get autoremove -y --purge
docker stop $(docker ps | grep -v '^CONTAINER' | awk '{print $1}')
docker rm $(docker ps -a | grep -v '^CONTAINER' | awk '{print $1}')
docker rmi $(docker images | grep -v '^REPOSITORY' | awk '{print $3}')
docker volume prune
sudo apt-get -y remove --purge containerd.io docker-ce docker-ce-cli && sudo apt-get autoremove -y --purge
sudo reboot
sudo rm -rf /var/lib/etcd /var/lib/kubelet /etc/kubernetes /etc/cni /var/lib/docker /var/lib/containerd /etc/containerd /etc/docker /var/lib/cni
rm -rf ~/.kube/
sudo reboot
```

##### NOTES - TO FINISH

##### /etc/kubernetes/manifests/kube-controller-manager.yaml
```
    - --node-monitor-period=2s
    - --node-monitor-grace-period=16s
    - --pod-eviction-timeout=5s
    - --feature-gates=TaintBasedEvictions=false
```

##### /var/lib/kubelet/config.yaml
```
--node-status-update-frequency=4s
```

https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/ TaintBasedEvictions
