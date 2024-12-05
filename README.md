# AWS-Terraform
Simple terraform script to provision and orchestrate resources in the cloud

# AWS VPC with EC2 and NGINX - Terraform Configuration

This repository contains a Terraform configuration to set up a basic AWS infrastructure, including a VPC, two public subnets, an internet gateway, and an EC2 instance running NGINX.

## **Table of Contents**
- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Configuration Details](#configuration-details)
- [License](#license)

---

## **Overview**
This configuration:
- Creates a VPC with CIDR block `10.0.0.0/16`.
- Provisions two public subnets across different availability zones.
- Adds an Internet Gateway to allow internet access.
- Deploys an EC2 instance with NGINX installed and configured.
- Configures security groups to allow SSH and HTTP traffic.

---

## **Architecture**
The setup creates the following infrastructure:
- **VPC**: A Virtual Private Cloud for network isolation.
- **Public Subnets**: Two subnets in different availability zones (`eu-central-1a` and `eu-central-1b`).
- **Internet Gateway**: Enables outbound internet access.
- **Route Table**: Routes traffic to the internet.
- **Security Group**: Allows SSH (port 22) and HTTP (port 80) access.
- **EC2 Instance**: A single t3.micro instance with NGINX installed.

---

## **Prerequisites**
To use this configuration, ensure you have:
1. [Terraform](https://www.terraform.io/downloads.html) version 1.5 or higher installed.
2. AWS CLI configured with a valid IAM user.
3. A key pair created in AWS (to SSH into the instance).

---

## **Usage**
1. Clone this repository:
   ```bash
   git clone https://github.com/langakipkoech/AWS-Terraform.git
   cd AWS-Terraform

  then run
  terraform init

  terraform validate

  terraform apply
  
