# Kubeadm Installation Guide

This guide outlines the steps needed to set up a Kubernetes cluster using kubeadm.

## Pre-requisites

* Ubuntu OS
* sudo privileges
* Internet access
* t2.medium instance type or higher (2 CPU's  Atleast 2GB RAM  Atleast 2GB Disk Space)

---
## Both Master & Worker Node

## Housekeeping Before Kubernetes Installation:
**Change of Hostname: To begin, it’s crucial to set a descriptive hostname for your node that reflects its role within your Kubernetes cluster.**
```
sudo apt install net-tools
```
```
sudo hostnamectl set-hostname master
```
**To make that change without closing your terminal:**
```
exec bash
```
**Update the /etc/hosts File:**
**Add a line: <private_IP hostname>**
```
sudo vi /etc/hosts
```
**Check IPs Workring or Not**
```
ping -c 5 master
```
**Run the following commands on both the master and worker nodes to prepare them for kubeadm.**
**SWAP is enable or not (Disable swap)**
```
free -h
```
```
swapoff -a
```
**To keep this change consistent even after a reboot, you need to modify the fstb file.**
```
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```
**Disable all the swap entries**
```
vi /etc/fstab
```
**Set up IP Bridge for nodes to communicate over the network:**
```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```
```
sudo modprobe overlay && sudo modprobe br_netfilter
```
```
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```
**To apply changes without reboot:**
```
sudo sysctl --system
```
**---------------------------------------------------------------------------------------------------------------------------------------------**
# Containerd
**Download containerd**
```
sudo wget https://github.com/containerd/containerd/releases/download/v1.6.22/containerd-1.6.22-linux-amd64.tar.gz
```
**Copy containerd to /usr/local**
```
sudo cp  containerd-1.6.22-linux-amd64.tar.gz /usr/local/
cd /usr/local
```
```
sudo tar -xvf containerd-1.6.22-linux-amd64.tar.gz
```
**Download containerd service**
```
sudo wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
```
```
sudo mv containerd.service /usr/lib/systemd/system/
```
**Enable containerd and check status**
```
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
sudo systemctl status containerd
```
**Version Installed: v1.6.22**
**Link:** https://github.com/containerd/containerd/releases
**---------------------------------------------------------------------------------------------------------------------------------------------**
# Explanation : Dependency for containerd container run time
**Install runc**
```
sudo wget https://github.com/opencontainers/runc/releases/download/v1.1.7/runc.amd64
```
```
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
```
**Version Installed: v1.1.7**
**Link:** https://github.com/opencontainers/runc/releases

**Install CNI Plugin**
```
sudo wget https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz
```
```
sudo cp cni-plugins-linux-amd64-v1.2.0.tgz /opt/cni/bin/
cd /opt/cni/bin
```
```
tar -xzvf cni-plugins-linux-amd64-v1.2.0.tgz
```
**Version Installed: v1.2.0**
**Link:** https://github.com/containernetworking/plugins/releases

**ERROR:-**
—------------**Replace**-----------------------------------

```
curl -fLo cni-plugins-linux-amd64-v1.1.1.tgz \
https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz
```
—-------------------------------------------------------------

 **Create Containerd Config file**
```
sudo mkdir -p /etc/containerd/
```
```
containerd config default | sudo tee /etc/containerd/config.toml
```

( **Explanation:** This command  is used to capture the default configuration of the containerd container runtime and write it to a file  config.toml )
```
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
```
 (**Explanation:** We are changing the systemcdCgroup value to true from false )
```
sudo systemctl restart containerd
```

**--------------------------------------------------------------------------------------------------------------------------------------------**

**Update Packages:**
```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```
```
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg 
```
**Note:** In releases older than Debian 12 and Ubuntu 22.04, /etc/apt/keyrings does not exist by default; you can create it by running 
```
sudo mkdir -m 755 /etc/apt/keyrings
```
```
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
```
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

**Note:** Expose port **6443** in the Security group for the Worker to connect to **Master Node**.
```
sudo kubeadm init
```
**Generate a token for worker nodes to join**
```
sudo kubeadm token create --print-join-command
```
# Worker Node
Run the following commands on the worker node.
```
sudo kubeadm reset pre-flight checks
```

**--------------------------------------------------------------------------------------------------------------------------------------------**

# Apply the calico yaml
**Version: v3.25.1**
kubectl create -f <calico_file.yaml>
	
**Note:** (update interface name, and pod cidr in line no 4581 and 4583)

( Explanation: By updating the interface name in the Calico YAML file, we are configuring Calico to use the correct network interface for communication between nodes in the cluster and if we are having multiple network interfaces, and you might want to specify which interface Calico should use )
Join the Worker nodes to Master (execute in workers only):

```
vim calio.yaml
```
```
kubectl create -f calio.yaml
```
kubectl apply -f calio.yaml
```
```

**Apply Weave network:Master**
```
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```


https://v1-28.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/






