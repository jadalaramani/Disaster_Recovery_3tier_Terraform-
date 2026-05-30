# Disaster_Recovery_3tier_Terraform
# AWS 3-Tier Application Disaster Recovery (Multi-Region) using Terraform

## Overview

This project implements a Disaster Recovery (DR) solution for a 3-Tier Application deployed across two AWS regions:

* **Primary Region:** us-east-1 (N. Virginia)
* **DR Region:** us-west-2 (Oregon)

---

# Architecture

### Primary Region (us-east-1)

* VPC
* Public & Private Subnets
* Bastion Host
* Frontend ALB
* Backend ALB
* EC2 Instances
* RDS Database
* Route53 Private Hosted Zone

### Disaster Recovery Region (us-west-2)

* VPC
* Public & Private Subnets
* Bastion Host
* Frontend ALB
* Backend ALB
* EC2 Instances
* RDS Read Replica
* Route53 Private Hosted Zone 

---

# Prerequisites

* AWS Account
* Terraform Installed
* Route53 Access
* ACM Permissions
* Bastion Host Access
* Domain Name (Example: `b17facebook.xyz`)

---

# Manual Configuration Steps

## 1. Create Route53 Public Hosted Zone

Create a public hosted zone:

```text
b17facebook.xyz
```

### Private Hosted Zone

Terraform creates:

```text
rds.com
```

for:

```text
us-east-1
```

For:

```text
us-west-2
```

Create the private hosted zone manually.

---

## 2. Create Database CNAME Records

Create the following record in both regions:

```text
book.rds.com
```

Type:

```text
CNAME
```

Value:

```text
<respective RDS endpoint>
```

Example:

```text
book.rds.com → mydb.xxxxxx.us-east-1.rds.amazonaws.com
```

```text
book.rds.com → mydb.xxxxxx.us-west-2.rds.amazonaws.com
```

> Note:
>
> Backend ALB now works correctly with database connectivity.
> Therefore, create `book.rds.com` before application deployment.

---

## 3. Create ACM Certificates

Create SSL certificates in:

* us-east-1
* us-west-2

For:

```text
b17facebook.xyz
*.b17facebook.xyz
```

Validate certificates using Route53.

---

## 4. Add HTTPS Listeners

Configure HTTPS listeners for:

### Frontend ALB

```text
443 → Target Group
```

### Backend ALB

```text
443 → Target Group
```

In both regions.

---

## 5. Create Route53 Health Check

Create a health check:

```text
Name:
3tier_healthcheck_backend_alb
```

Target:

```text
Primary Region Backend ALB
(us-east-1)
```

Protocol:

```text
HTTPS
```

Path:

```text
/
```

---

## 6. Configure Backend Failover Record

### Primary Record

Hosted Zone:

```text
b17facebook.xyz
```

Record:

```text
api.b17facebook.xyz
```

Type:

```text
A (Alias)
```

Target:

```text
Primary Backend ALB
(us-east-1)
```

Routing Policy:

```text
Failover
```

Failover Type:

```text
Primary
```

Attach:

```text
3tier_healthcheck_backend_alb
```

---

### Secondary Record

Hosted Zone:

```text
b17facebook.xyz
```

Record:

```text
api.b17facebook.xyz
```

Type:

```text
A (Alias)
```

Target:

```text
DR Backend ALB
(us-west-2)
```

Routing Policy:

```text
Failover
```

Failover Type:

```text
Secondary
```

Health Check:

```text
Not Required
```

---

## 7. Configure Database

Connect to backend EC2 through Bastion Host.

```bash
cd aws_three_tier_code/

cd backend/

cat .env

sudo pm2 list

sudo pm2 logs backendAPI
```

Install MySQL Client if required:

```bash
sudo apt update
sudo apt install mysql-server -y
```

Load Database:

```bash
mysql -h book.rds.com -u admin -ppassword123 test < test.sql
```

Verify successful import.

---

## 8. Configure Frontend Failover Records

Create Route53 records for Frontend ALBs.

### Frontend Record

```text
bookstore.b17facebook.xyz
```

Type:

```text
A (Alias)
```

Target:

```text
Frontend ALB
(us-east-1)
```

Routing Policy:

```text
simple
```

---

# Disaster Recovery Testing

## Simulate Failure

Stop:

* Backend EC2
* Backend Application
* Backend ALB Target Group

OR

Make health check fail intentionally.

---

## Expected Result

Route53 automatically redirects traffic:

```text
Primary Region
     ↓
Health Check Failure
     ↓
Secondary Region (Oregon)
```

Application continues serving requests from DR Region.

---

# Validation Checklist

* [ ] Terraform Apply Successful
* [ ] Public Hosted Zone Created
* [ ] Private Hosted Zone Created
* [ ] book.rds.com Configured
* [ ] ACM Certificates Issued
* [ ] HTTPS Listeners Added
* [ ] Backend Failover Records Created
* [ ] Frontend Failover Records Created
* [ ] Database Imported
* [ ] PM2 Services Running
* [ ] DR Failover Tested Successfully

---

# Repository

Terraform provisions:

* Networking
* Security Groups
* Bastion Host
* Frontend Infrastructure
* Backend Infrastructure
* RDS
* Route53 Private DNS
* Cross-Region Disaster Recovery Components

Manual steps are required only for ACM, Route53 Failover Records, Health Checks, and Initial Database Configuration.

## Destroy infrastructure
```
terraform destroy --auto-approve
```


