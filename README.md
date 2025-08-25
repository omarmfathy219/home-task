# DevOps Development Environment

A complete EKS cluster environment with Kubernetes, monitoring, and infrastructure as code.

## Overview

Deploy on **AWS EKS** with:
- **EKS Cluster**: Managed Kubernetes cluster
- **Monitoring**: Prometheus + Grafana + AlertManager
- **Ingress**: NGINX with SSL/TLS certificates
- **Infrastructure**: Terraform modules for AWS

## Prerequisites

- AWS CLI + Terraform
- kubectl + helm

## Quick Start

```bash
# Deploy infrastructure
cd terraform/environments/development
terraform init && terraform apply

# Configure kubectl
aws eks update-kubeconfig --region us-west-2 --name devops-cluster

# Install monitoring stack (Prometheus + Grafana + AlertManager)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.service.type=LoadBalancer

# Deploy simple NGINX app
kubectl create deployment nginx --image=nginx:alpine
kubectl expose deployment nginx --port=80 --type=ClusterIP

# Access monitoring
kubectl port-forward -n monitoring svc/grafana 3000:80
```

## Project Structure

```
.
├── README.md
└── terraform/
    ├── aws/              # Main AWS configuration
    ├── modules/          # Reusable Terraform modules (VPC, EKS)
    └── environments/     # Environment-specific configs
```

## Monitoring

The monitoring stack is installed via Helm and includes:
- **Prometheus**: Metrics collection and storage
- **Grafana**: Dashboards and visualization  
- **AlertManager**: Alert routing and notifications

## Architecture Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                        Infrastructure Layer                     │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │   AWS VPC   │  │   EKS       │  │   S3        │              │
│  │             │  │   Cluster   │  │   Storage   │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Kubernetes Layer                           │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │  NGINX      │  │  Cert-      │  │  Monitoring │              │
│  │  Ingress    │  │  Manager    │  │  Stack      │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Monitoring Layer                           │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ Prometheus  │  │  Grafana    │  │  Alert      │              │
│  │  Metrics    │  │  Dashboards │  │  Manager    │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

### Layer Details
- **Infrastructure**: AWS VPC, EKS Cluster, S3 Storage
- **Kubernetes**: NGINX Ingress, Cert-Manager, Monitoring Stack
- **Monitoring**: Prometheus, Grafana, AlertManager

## Key Features

- **Auto-scaling**: HPA and Cluster Autoscaler
- **Security**: RBAC, Network Policies, Pod Security Standards
- **Monitoring**: Prometheus + Grafana + AlertManager
- **SSL**: Automatic certificate management with Cert-Manager
- **Load Balancing**: NGINX Ingress + AWS ALB