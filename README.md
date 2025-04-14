# Alison

Alison is a app-based application deployed on AWS using Terraform for infrastructure and GitHub Actions for CI/CD. It consists of two apps that communicate through AWS SQS and store data in S3.

## Project Components

### Infrastructure (Terraform)

The infrastructure is defined using Terraform modules:

- **ECS**: Manages the ECS cluster, services, and task definitions for the apps
- **ECR**: Container registries for both apps
- **S3**: Storage bucket for app2 outputs
- **SQS**: Message queue for communication between apps
- **SSM**: Parameter store for secure token storage
- **ELB**: Application Load Balancer for routing traffic to app1

### CI/CD Pipeline (GitHub Actions)

The CI/CD pipeline consists of three workflows:

1. **CI Workflow**: Builds, tests, and pushes Docker images to ECR
   - Runs unit tests for both apps
   - Builds Docker images with proper tags
   - Pushes images to ECR repositories

2. **CD Workflow**: Deploys services to ECS
   - Updates ECS services to use the latest container images
   - Forces new deployments

3. **Main Pipeline**: Orchestrates CI and CD workflows
   - Runs on pushes to the main branch
   - Can be manually triggered to deploy to specific environments

## Project Setup Guide

### Prerequisites

- AWS CLI installed and configured with appropriate credentials
- Terraform installed (v1.0.0+)
- Git

### Setting Up the Infrastructure

1. **Create Backend Resources**

   Before applying Terraform, create the required S3 bucket state management and specify it in ./terraform/backend.tf

   ```bash
   # Export the bucket name for use in commands
   export TF_BUCKET=jona-cp
   
   # Create S3 bucket
   aws s3api create-bucket \
     --bucket $TF_BUCKET \
     --region us-west-2 \
     --create-bucket-configuration LocationConstraint=us-west-2   
   ```


2. **Initialize and Apply Terraform with the current workflows**

   ```bash
   .github/workflows/Terraform-Create.yaml
   .github/workflows/terraform-destroy.yml
   ```

### Setting Up CI/CD

1. **Add Repository Secrets in GitHub**

   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY

2. **Push to Main Branch**

   - Pushing to main will trigger the CI/CD pipeline

## apps

- **app1**: RESTful API that validates inputs and sends messages to SQS
- **app2**: Background worker that processes SQS messages and stores them in S3

## Monitoring with prometheus and grafana #TODO




## Triggering apps via ALB

To test the apps after deployment, you can send a request to app1 via the Application Load Balancer:

```bash
# Replace <ALB-DNS-URL> with your actual ALB DNS name from terraform output
# This request includes the authentication token from your environment variables

curl -X POST http://<ALB-DNS-URL> \
  -H "Content-Type: application/json" \
  -d '{
    "token": "'"$TF_VAR_token_value"'",
    "data": {
      "email_subject": "Happy new year!",
      "email_sender": "John Doe",
      "email_timestream": "1693561101",
      "email_content": "Just want to say... Happy new year!!!"
    }
  }'
```

Field descriptions:
- `email_subject`: The subject line of the email
- `email_sender`: The name of the person or entity sending the email
- `email_timestream`: A timestamp (in Unix format) indicating when the email was created
- `email_content`: The body content of the email message
- `token`: A secure token used for authentication (should match the one in SSM)


```bash
cd app1
python -m unittest discover -s tests

cd ../app2
python -m unittest discover -s tests
```



