# Terraform Project Structure

This repository contains Terraform configuration files for setting up AWS infrastructure.

## File Structure

| File Name               | Description |
|-------------------------|-------------|
| `main.tf`              | Main entry point for Terraform execution. |
| `variables.tf`         | Defines variables for reusability and configuration. |
| `outputs.tf`           | Specifies Terraform output values. |
| `vpc.tf`              | Contains AWS Provider setup and VPC configuration. |
| `subnets.tf`          | Defines public and private subnets in different availability zones. |
| `internet_gateway.tf` | Configures the Internet Gateway and public route tables. |
| `security_groups.tf`  | Sets up security groups for Load Balancer and other resources. |
| `elb.tf`              | Creates an Elastic Load Balancer (ELB) with necessary listeners. |
| `route53.tf`          | Configures Route 53 hosted zone and DNS records. |
