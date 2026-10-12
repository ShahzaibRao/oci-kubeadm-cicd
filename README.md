# oci-kubeadm-cicd

Production-grade CI/CD pipeline on Oracle Cloud Free Tier — self-managed
Kubernetes (kubeadm) on 2 ARM VMs, GitHub Actions CI, Docker Hub registry,
Argo CD + Argo Rollouts GitOps. Sirf production pipeline (staging skipped).

> Learning project + DevOps interview prep.
> Poora design: docs/ mein (47-page design document).

## Architecture

GitHub (app repo) → GitHub Actions (test/scan/build) → Docker Hub (SHA tags)
→ gitops repo (digest pin) → Argo CD → kubeadm cluster
→ Argo Rollouts canary 90/10 (NGINX) → Prometheus analysis → auto promote/rollback

Internet → OCI LB → NGINX Ingress → app pods

## Phases

- Phase 0: OCI infra — Terraform, 2× ARM VMs (2 OCPU / 12 GB)
- Phase 1: kubeadm cluster — Ansible (containerd, Calico, NGINX ingress)
- Phase 2: Argo CD, Argo Rollouts, ESO, monitoring — Ansible
- Phase 3: OCI Vault + ExternalSecrets
- Phase 4: PR pipeline — lint, test, coverage, gitleaks, SonarCloud, Trivy
- Phase 5: Build & push — SHA tags, Docker Hub
- Phase 6: GitOps promotion — digest pin, CODEOWNERS
- Phase 7: Canary 90/10 + auto rollback
- Phase 8+: Observability, hardening, demo

## Rules

- Koi secret hardcode nahi — OCI Vault + ESO
- CI kabhi cluster ko touch nahi karta
- Har change PR se, prod values CODEOWNERS protected
