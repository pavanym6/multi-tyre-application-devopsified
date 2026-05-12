## Repository Structure

```
Three-Tier-Application-AIOps/          
├── projects/
│   ├── README.md                  # EKS deployment guide 
│   ├── boutique-microservices/    # The application (7 services)
│   ├── Infrastructure/            # Terraform for AWS provisioning
│   └── aiops-assistant/           # Bedrock Agent — Kira 
├── gitops/
│   ├── argo-cd.yml                # ArgoCD Application manifest
│   ├── kustomization.yml          # Kustomize entry point
│   └── k8s/                       # All Kubernetes manifests
└── .github/
    └── workflows/ci.yml           # GitHub Actions CI pipeline
