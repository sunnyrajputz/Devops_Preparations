# Key Steps:

1. Upgrade the EKS control plane (master nodes).
2. Upgrade the worker nodes (EC2 instances).
3. Ensure workloads are rescheduled and running without disruptions.

# Step-by-Step Process
1. Check the current EKS Cluster Version

Before performing any upgrade, you should verify the current version of your cluster.
```
aws eks describe-cluster --name <cluster-name> --query "cluster.version"
```
2. Choose the new EKS Cluster Version

Find the available versions for your EKS cluster by checking the EKS release notes or using AWS CLI to list the available Kubernetes versions.
```
aws eks describe-cluster --name <cluster-name> --query "cluster.version"
aws eks list-clusters
```
3. Upgrade the EKS Control Plane (Master Nodes)

To upgrade the control plane to a new Kubernetes version, you will use the following AWS CLI command. This step is non-disruptive because AWS automatically handles the process for you.
```
aws eks update-cluster-version --name <cluster-name> --kubernetes-version <new-version>
```
Example:
```
aws eks update-cluster-version --name my-cluster --kubernetes-version 1.23
```

This will initiate the upgrade of the control plane. AWS will automatically upgrade the master node, and there will be no downtime as it will ensure high availability by upgrading control planes in a rolling manner across multiple availability zones.
You can track the progress of the upgrade:

```
aws eks describe-cluster --name <cluster-name> --query "cluster.status"
```
The status will indicate when the upgrade is complete.
4. Upgrade Worker Nodes (EC2 Instances)
After upgrading the control plane, you must upgrade the worker nodes to a compatible version. If you're using managed node groups, you can upgrade them directly.
Upgrade Managed Node Group:
```
aws eks update-nodegroup-version --cluster-name <cluster-name> --nodegroup-name <nodegroup-name> --kubernetes-version <new-version>
```
Example:
```
aws eks update-nodegroup-version --cluster-name my-cluster --nodegroup-name my-nodegroup --kubernetes-version 1.23
```

This will upgrade the worker nodes to the new Kubernetes version. EKS will automatically create new nodes, then drain and terminate the old ones. The process is non-disruptive to your workloads if you follow the correct steps for draining nodes.


# Upgrade Self-Managed Node Groups:
For self-managed node groups, you need to manually update the EC2 instance AMI, which corresponds to the new Kubernetes version. Here are the steps:

1. Update the EC2 Instances' AMI to use a Kubernetes-compatible AMI:
Find the latest AMI for your desired Kubernetes version:
```
aws ssm get-parameters --names "/aws/service/eks/optimized-ami/<Kubernetes-Version>/amazon-linux-2/recommended/image_id" --query "Parameters[0].Value" --output text
```
2. Launch New EC2 Instances with the new AMI, ensuring that they are added to the EKS cluster and can join as worker nodes.
3. Drain Old Nodes (This ensures that your pods are safely moved to the new worker nodes, avoiding downtime):
```
kubectl drain <node-name> --ignore-daemonsets --delete-local-data
```
Repeat this for each old node. This will ensure that workloads are moved to the new nodes before terminating the old ones.

4. Terminate the Old Nodes once the new nodes are up and running.
```
aws ec2 terminate-instances --instance-ids <instance-id>
```

5. Upgrade Add-ons (CoreDNS, kube-proxy, etc.)
After upgrading the control plane and worker nodes, you also need to ensure that EKS add-ons are upgraded to the appropriate version. For example, you can update CoreDNS and kube-proxy as follows
```
aws eks update-addon --cluster-name <cluster-name> --addon-name coredns --addon-version <new-version>
aws eks update-addon --cluster-name <cluster-name> --addon-name kube-proxy --addon-version <new-version>
```

6. Verify Cluster and Workload Health
After the upgrade is completed, ensure that everything is functioning correctly:
1. Check Node Status:
```
kubectl get nodes
```
Ensure all nodes are in the Ready state.
2. Check Pod Status:
```
kubectl get pods --all-namespaces
```
Make sure that all pods are running as expected.
3. Verify Cluster Version:
```
kubectl version
```
This will display the client and server (control plane) versions to ensure the upgrade was successful.

Best Practices to Avoid Downtime During the Upgrade
1. Use Rolling Updates:
When upgrading the worker nodes, use PodDisruptionBudgets (PDBs) to ensure that a minimum number of replicas are always running.
Example of creating a PodDisruptionBudget:
yaml
```
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: my-app
```

2. Upgrade in Stages:
Upgrade the control plane first, then the worker nodes. Make sure to allow the new nodes to become fully operational before terminating the old nodes.
3. Monitor the Upgrade:
Use AWS CloudWatch and Kubernetes metrics to monitor the cluster’s performance and pod health during the upgrade.
4. Ensure Backups:
Always take regular backups of your Kubernetes configurations, including manifests, secrets, and persistent storage data.

