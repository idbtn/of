Architecture Design for "Innovate Inc."
======================================

Version: 2025/11/20

# Project scope

Objective:
- Design a cloud infrastructure for Innovate Inc.'s WEB Application.
Client background: 
- Innovate Inc. is a startup that aims to develop a scalable web application that implements the Single Page Application (SPA) paradigm.


## System Overview
* The application needs to rapidly scale from 200 daily users up to 5 milion users.
* The service will handle sensitive user data and need to be GDPR and HIPAA compliant.

## Components

Frontend:
- Containerized SPA Web Application

Backend:
- Containerized REST API Microservice

Data:
- Highly Available RDS PostgreSQL instances with Primary and Read Replicas.


## Cloud Environment Structure

AWS Accounts:
- Management:
    - Billing
    - Service Control Policies (SCPs)
    - Manage Member Accounts
    - Centralize CloudTrail logs.
    - Centralized Identity Management
- Development
- Staging
- Production

## Cloud Components

## Data Flow

## Security Architecture
- Identity and Access Management (IAM)
- Network Security
    - Subnets
        - Public subnets
        - Private subnets
    - Security Groups
        - Load Balancer SG
        - Application SG
        - Database SG
    - Encryption standards
        - Data at Rest
            - S3 Objects
            - Database
        - Data in transit
            - External traffic
            - Internal traffic
- Deployment
    - Pre-requisites
    - Configuration Steps
    - Verification Steps

- Monitoring
    - Metrics
    - Alerts
    - Dashboards

- Disaster Recovery
    - Backup Procedures
    - Recovery Steps
    - Contact Information

- Version Control Strategy
    - Branches:
        - dev -> Development environment
            - PR required
            - Auto-deploy on merge
        - staging -> Staging environment
            - PR required
            - Auto-deploy on merge
        - main -> Production
            - Protected
            - PR required
            - Tests must pass
            - Must be reviewed
            - No force pushes
            - No direct commits
    - Promotion flow: 
        - feature -> dev -> staging -> main
    - CI triggers:
        - On pull requests (tests, lint, static analysis)
        - On merge into dev / staging / main
    - Pull Request Workflow:
        - PR checks:
            - Automatic tests
            - Static code analysis
            - Code style linting
            - Security Scanning
        - PR approval:
            - At least 1 reviewer (2 for prod-critical code)
        - PR merge strategy:
            - Merge commit to preserve history
    - Tagging:
        - Every production deployment from main is tagged.
        - Tags trigger additional CI pipelines:
            - Artifact packaging
            - Helm chart versioning

- Logging
    - Application Logs
    - Security Logs
    - Performance Logs

Observations:
    - In order to implement a working scaling plan, the services need to be load tested to determine if the application is compute / memory intensive when being scaled.
    - Required information:
        - minimum resources for Backend / Frontend containers to run, and the number of supported users for the minimal deployment unit.
        - Load testing 2X, 5X, 10X, 50X to gather users and resource consumption statistics to determine a scaling pattern.


