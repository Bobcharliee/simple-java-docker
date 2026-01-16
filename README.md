# Simple Java Web Application Deployment with Tomcat, Ansible, Terraform, and GitHub Actions

## Overview

This project demonstrates a **complete CI/CD pipeline** for building, packaging, and deploying a Java web application (`WAR`) to an **Apache Tomcat** server running on **AWS EC2**.

The solution integrates:

* **Java + Maven** for application build
* **Apache Tomcat 10** as the application server
* **Terraform** for infrastructure provisioning
* **Ansible** for configuration management and deployment
* **GitHub Actions** for continuous integration and delivery

The goal of the project is to show a **realistic DevOps workflow**: from source code commit → automated build → deployment to a live server.

---

## Architecture

```
   Push
     │
     ▼
GitHub Repository (Main)
     │
     ▼
GitHub Actions (CI)
  - Build WAR using Maven
  - Run Ansible Playbook
     │
     ▼
AWS EC2 Instance
  - Java 11 (Amazon Corretto)
  - Apache Tomcat 10
  - Deployed WAR Application
```

---

## Prerequisites

### Local / CI Requirements

* Java 11+
* Apache Maven 3.8+
* Git

### AWS Requirements

* AWS account
* EC2 instance (Amazon Linux 2 / AL2023)
* Security Group allowing:

  * TCP 22 (SSH)
  * TCP 8080 (Tomcat)

### GitHub Secrets

The following secrets must be configured in the repository:

| Secret Name   | Description                           |
| ------------- | ------------------------------------- |
| `EC2_HOST`    | Public IP or DNS of EC2 instance      |
| `EC2_SSH_KEY` | Private SSH key (PEM) used by Ansible |

---

## Application Details

* **Packaging Type:** WAR
* **Servlet API:** Jakarta Servlet 6 (provided by Tomcat)
* **Java Version:** 11

### pom.xml Highlights

```xml
<packaging>war</packaging>
```

The WAR is generated at:

```
target/java-webapp-1.0.0.war
```

---

## Infrastructure Provisioning (Terraform)

Terraform is used to:

* Provision EC2 instance
* Configure networking and security groups
* Attach SSH key pair

Example:

```bash
terraform init
terraform apply
```

---

## Configuration Management (Ansible)

### 1. Java Installation (`install-java.yml`)

This playbook:

* Installs Java (Amazon Corretto) on EC2 instance
* Installs java-11-amazon-corretto 

Run manually:

```bash
ansible-playbook -i inventory.ini install-java.yml
```

---

### 2. Tomcat Installation (`install-tomcat.yml`)

This playbook:

* Downloads Apache Tomcat 10
* Creates `tomcat` user and group
* Configures Tomcat as a systemd service
* Ensures correct permissions

Run manually:

```bash
ansible-playbook -i inventory.ini install-tomcat.yml
```

---

### 3. Application Deployment (`deploy-war.yml`)

This playbook:

* Copies the WAR file to Tomcat `webapps/`
* Sets correct ownership
* Restarts Tomcat

Key task:

```yaml
copy:
  src: /home/runner/work/simple-java-docker/simple-java-docker/target/java-webapp-1.0.0.war
  dest: /opt/tomcat/apache-tomcat-10.1.50/webapps/java-webapp.war
```

---

## CI/CD Pipeline (GitHub Actions)

### Workflow Steps

1. Checkout repository
2. Set up Java
3. Build WAR using Maven
4. Verify build artifacts
5. Configure SSH for Ansible
6. Deploy WAR to EC2 using Ansible

### Trigger

```yaml
on:
  push:
    branches:
      - main
```

---

## Verifying Deployment

<img width="1268" height="643" alt="Screenshot 2026-01-16 164341" src="https://github.com/user-attachments/assets/3cc05d53-ba47-4975-abab-71bf7f7a2e2d" />


### Check Tomcat Status

```bash
sudo systemctl status tomcat
```
<img width="994" height="158" alt="Screenshot 2026-01-16 164826" src="https://github.com/user-attachments/assets/8de24115-91c5-49c7-9d33-9310de5fa954" />



### Confirm WAR Deployment

```bash
ls /opt/tomcat/apache-tomcat-10.1.50/webapps
```

Expected:

```
java-webapp.war
java-webapp/
```

### Test Application

```bash
curl http://<EC2_PUBLIC_IP>:8080/java-webapp/
```

---

## Logging & Troubleshooting

### Tomcat Logs (systemd)

```bash
sudo journalctl -u tomcat --no-pager
```

### Common Issues

| Issue              | Cause                 | Fix               |
| ------------------ | --------------------- | ----------------- |
| WAR not found      | Wrong Ansible path    | Use absolute path |
| SSH denied         | Missing key in runner | Use GitHub secret |
| App not accessible | WAR not deployed      | Restart Tomcat    |

---

## Security Considerations

* SSH keys are stored as GitHub secrets
* No credentials are committed to the repository
* Tomcat runs under a non-root user

---

