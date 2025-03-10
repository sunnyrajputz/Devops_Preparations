# Kubeadm Installation Guide

This guide outlines the steps needed to set up a Kubernetes cluster using kubeadm.

## Pre-requisites

* Ubuntu OS (Xenial or later)
* sudo privileges
* Internet access
* t2.medium instance type or higher (2 CPU's  Atleast 2GB RAM  Atleast 2GB Disk Space)

---
## Both Master & Worker Node

## Housekeeping Before Kubernetes Installation:
**Change of Hostname: To begin, it’s crucial to set a descriptive hostname for your node that reflects its role within your Kubernetes cluster.**
```
sudo hostnamectl set-hostname master
```
**To make that change without closing your terminal:**
```
exec bash
```
# Update the /etc/hosts File:
**Add a line: your-desired-hostname**
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
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward		            = 1
EOF
```
**To apply changes without reboot:**
```
sudo sysctl --system
```

```bash
sudo apt update
sudo apt-get install -y apt-transport-https ca-certificates curl
```
**Install docker.**
```
sudo apt install docker.io -y
```

**Enable and start in single command.**
```
sudo systemctl enable --now docker 
```

**Adding GPG keys.**
```
curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg
```
**OR**
```
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
```
**Add the repository to the sourcelist.**
```
echo 'deb https://packages.cloud.google.com/apt kubernetes-xenial main' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
**OR**
```
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
**Update Packages:**
```
sudo apt update
```
**Install Kubeadm supported version:**
```
sudo apt install kubeadm=1.20.0-00 kubectl=1.20.0-00 kubelet=1.20.0-00 -y
```
---

## Master Node

1. Initialize the Kubernetes master node.

    ```bash
    sudo kubeadm init
    ```
    After succesfully running, your Kubernetes control plane will be initialized successfully.

3. Set up local kubeconfig (both for root user and normal user):

    ```bash
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    ```

4. Apply Weave network:

    ```bash
    kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
    ```

5. Generate a token for worker nodes to join:

    ```bash
    sudo kubeadm token create --print-join-command
    ```

    <kbd>![image](https://github.com/paragpallavsingh/kubernetes-kickstarter/assets/40052830/0370839b-bbac-415c-9d5a-9ab52cd3108b)</kbd>

6. Expose port 6443 in the Security group for the Worker to connect to Master Node

<kbd>![image](https://github.com/paragpallavsingh/kubernetes-kickstarter/assets/40052830/b3f5df01-acb0-419f-aa70-6d51819f4ec0)</kbd>


---

## Worker Node

1. Run the following commands on the worker node.

    ```bash
    sudo kubeadm reset pre-flight checks
    ```
    # Note : **  --v=5  **
2. Paste the join command you got from the master node and append `**--v=5`** at the end.
*Make sure either you are working as sudo user or use `sudo` before the command*

   <kbd>![image](https://github.com/paragpallavsingh/kubernetes-kickstarter/assets/40052830/c41e3213-7474-43f9-9a7b-a75694be582a)</kbd>

---

**Verify Cluster Connection**

On Master Node:

```bash
kubectl get nodes
```
---

## Optional: Labeling Nodes

If you want to label worker nodes, you can use the following command:

```bash
kubectl label node <node-name> node-role.kubernetes.io/worker=worker
```

---

## Optional: Test a demo Pod 

If you want to test a demo pod, you can use the following command:

```bash
kubectl run hello-world-pod --image=busybox --restart=Never --command -- sh -c "echo 'Hello, World' && sleep 3600"
```

<kbd>![image](https://github.com/paragpallavsingh/kubernetes-kickstarter/assets/40052830/bace1884-bbba-4e2f-8fb2-83bbba819d08)</kbd>
