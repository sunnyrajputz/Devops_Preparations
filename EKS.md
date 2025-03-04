# What is EKS?

Amazon Elastic Kubernetes Service (EKS) is a fully managed Kubernetes service provided by Amazon Web Services (AWS). It makes it easier to deploy, manage, and scale containerized applications using Kubernetes on AWS. EKS automatically handles the availability and scalability of the Kubernetes control plane, including patching and upgrades. It integrates with various AWS services, making it a powerful option for managing containerized applications in the cloud.

# Components of EKS

EKS consists of the following key components:
1. EKS Control Plane:
The managed Kubernetes control plane includes the Kubernetes master nodes responsible for cluster management (e.g., API server, controller manager, etc.). AWS manages this control plane, ensuring its availability and scaling.
2. Worker Nodes:
These are EC2 instances that run your containerized applications. Worker nodes are managed by the Kubernetes control plane and run your Pods (the smallest deployable units in Kubernetes).
3. Amazon EC2 Instances:
Worker nodes are typically EC2 instances running within your VPC. These instances host the containers running your applications.
4. VPC (Virtual Private Cloud):
EKS clusters are deployed in a VPC, which provides network isolation. The VPC defines the network boundaries in which the worker nodes and other components reside.
5. IAM (Identity and Access Management):
EKS uses IAM for user and service access management. IAM roles and policies are used to control who can access and manage the Kubernetes cluster and its components.
6. Amazon ECR (Elastic Container Registry):
ECR is often used to store container images that are pulled into EKS for deployment. You can use your private registry to manage container images that EKS uses.
7. CloudWatch:
CloudWatch is used for logging and monitoring Kubernetes clusters and applications running on EKS. It helps in observability and troubleshooting.
8. AWS Auto Scaling:
EKS integrates with AWS Auto Scaling to dynamically scale the number of EC2 instances (worker nodes) based on demand.

# How EKS Works

1. EKS Cluster Setup:

* You create an EKS cluster in the AWS Management Console, specifying the VPC, subnets, and other configurations.
* EKS sets up a managed Kubernetes control plane (master nodes), which is highly available and automatically scaled.

2. Worker Nodes Setup:
* You configure worker nodes (EC2 instances) that will run your containerized applications.
* These nodes are registered with the Kubernetes control plane. EKS manages the lifecycle of these nodes.

3. Deploying Applications:
* After the cluster is set up, you can deploy containerized applications to the cluster using standard Kubernetes deployment tools (kubectl, Helm, etc.).
* The Kubernetes scheduler deploys these applications across the available worker nodes.

4. Cluster Management:
* EKS automatically manages the Kubernetes control plane, such as scaling, patching, and ensuring high availability.
* You can manage the Kubernetes workloads through the Kubernetes API, AWS CLI, or other management tools.


# Components Required for EKS Cluster Version Upgrade
To upgrade your EKS cluster version, several components must be considered:
1. EKS Control Plane Version:
* AWS manages the version of the EKS control plane. This is what you typically upgrade to take advantage of new Kubernetes features, security patches, and bug fixes.
2. Kubernetes Node Version:
* The worker nodes running your applications must be compatible with the new control plane version. You need to upgrade the node AMI (Amazon Machine Image) to match the Kubernetes version you are upgrading to.
3. Node Group Configuration:
* EKS supports managed node groups. When upgrading the cluster version, you might also need to upgrade your managed node groups to use the appropriate Kubernetes version.
4. Add-ons (e.g., CoreDNS, kube-proxy):
* EKS uses add-ons for various services like CoreDNS, kube-proxy, etc. These should be updated to be compatible with the new Kubernetes version.
5. Helm and Other Third-Party Applications:
* If you’re using Helm or other third-party applications, ensure they are compatible with the new Kubernetes version.
