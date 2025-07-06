# Jenkins Pipeline w/ Snyk Security & Terraform

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen?style=flat-square&logo=jenkins)](https://www.jenkins.io/)
[![Node.js](https://img.shields.io/badge/node-24.x-brightgreen?style=flat-square&logo=node.js)](https://nodejs.org/)
[![Snyk Scanning](https://img.shields.io/badge/security-scanned--by--snyk-blueviolet?style=flat-square&logo=snyk)](https://snyk.io)

---

## 📌 Overview

This repository contains a **secure CI/CD pipeline** using Jenkins for:

- ✅ Code checkout from GitHub
- ✅ Dependency management and auditing
- ✅ Security scanning via [Snyk.](https://snyk.io)
- ✅ Infrastructure provisioning with Terraform
- ✅ Deployment approval workflows
- ✅ Optional resource teardown

---

## 📂 Repository Structure

```plaintext
.
├── .gitignore
├── 0-Auth.tf                 # AWS provider
├── 1-VPC.tf                  # VPC setup
├── 2-Subnets.tf              # Subnet definitions
├── 3-IGW.tf                  # Internet Gateway
├── 4-Route.tf                # Route tables
├── 5-SG-All.tf               # Security groups
├── 6-TGW.tf                  # Transit Gateway
├── 7-TGW-Attachments.tf      # TGW attachments
├── 8-Instances.tf            # EC2 instances
├── Jenkinsfile               # Jenkins pipeline for Snyk + Terraform
├── package.json              # Node.js project config
├── README.md                 # Project documentation
├── snyk.sh                   # Optional shell wrapper for Snyk
```

---

## 🚀 Pipeline Breakdown

The pipeline (`Jenkinsfile`) uses **declarative syntax** and includes the following stages:

### 1️⃣ Set AWS Credentials

- Injects AWS keys from `snyk_cred`
- Verifies identity using: `aws sts get-caller-identity`

### 2️⃣ Checkout Code

- Pulls from the `main` branch of the GitHub repo

### 3️⃣ Install Snyk

- Installs `snyk` CLI and `snyk-to-sarif` for report conversion

### 4️⃣ Update Dependencies

- Uses `npm-check-updates (ncu)` to upgrade outdated packages
- Runs `npm install` after upgrade

### 5️⃣ Install Project Dependencies

- Checks for `package.json` and installs using `npm install`

### 6️⃣ Snyk Scan + SARIF Export

- Authenticates with `SNYK_TOKEN`
- Executes `snyk test --all-projects`
- Outputs JSON + SARIF report
- Uploads to [Snyk Dashboard](https://snyk.io)

### 7️⃣ Terraform Initialization & Plan

- Executes:
  - `terraform init`
  - `terraform validate`
  - `terraform plan`

### 8️⃣ Terraform Apply

- Approval-gated
- Executes: `terraform apply -auto-approve`

### 9️⃣ Application Deploy

- Placeholder for business logic post-infrastructure deployment

### 🔟 Terraform Destroy

- Optional, gated `terraform destroy -auto-approve` stage with manual approval

---

## 🔧 Jenkins Configuration

### 🔹 Required Plugins

- `Pipeline` (via Jenkins)
- `NodeJS Plugin`
- `AWS SDK`
- `Credentials Binding Plugin`
- `Snyk Security Plugin`
- `Git Plugin`

### 🔹 Global Tool Configuration

- **NodeJS Tool Name**: `NodeJS-24`
  - Version: Node.js 24.x
  - `Install automatically` enabled

### 🔹 Credentials

| ID             | Type         | Used For                            |
|----------------|--------------|-------------------------------------|
| `snyk_cred`    | AWS          | AWS CLI + Terraform auth            |
| `SNYK_TOKEN`   | Secret Text  | Snyk CLI authentication             |
| `GITHUB_TOKEN` | Secret Text  | _Optional_ – SARIF upload to GitHub   |

---

## 💪 How to Run

1. Push the `Jenkinsfile` to your repo
2. Create a `Pipeline` or `Freestyle Project`
3. Add required credentials and tools in Jenkins UI
4. Run the job
5. Observe the status of the Pipeline in `Console Output`.
6. Once the Pipeline is complete view the history in `Pipeline Overview` or `Pipeline Console`.

---

## 🧪 Local Testing (Optional)

### 🔹 Run Snyk Scan Locally

```bash
export SNYK_TOKEN=<your-snyk-token>
npm install -g snyk snyk-to-sarif
snyk test --all-projects --json > snyk.json
snyk-to-sarif < snyk.json > snyk.sarif
```

### 🔹 Run Terraform Commands Locally

```bash
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

---

## 📈 GitHub Security Dashboard Integration

To upload SARIF scan results:

1. Generate a GitHub token with `security_events` scope
2. Use GitHub's SARIF upload API or GitHub Actions (optional)
3. Snyk's CLI also supports direct GitHub integration

---
