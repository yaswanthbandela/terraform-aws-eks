# VPC Module - Terraform Backend Setup

## Prerequisites
Ensure you have the AWS CLI installed and configured with the necessary permissions.

## Setting up Terraform Backend
Terraform requires an S3 bucket to store the remote state and a DynamoDB table to handle state locking.

### 1. Create an S3 Bucket for Remote State Storage
Run the following command to create the S3 bucket in the `<AWS_REGION>` region:

```bash
aws s3api create-bucket --bucket <S3_BUCKET_NAME> --region <AWS_REGION>
```

### 2. Enable Versioning on the S3 Bucket
Versioning helps protect the state file from accidental deletions or overwrites.

```bash
aws s3api put-bucket-versioning --bucket <S3_BUCKET_NAME> --versioning-configuration Status=Enabled
```

### 3. Create a DynamoDB Table for State Locking
A DynamoDB table is used to enable state locking and prevent concurrent Terraform runs.

```bash
aws dynamodb create-table \
    --table-name <DYNAMODB_TABLE_NAME> \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
```

### 4. Verify the Created Resources
To check if the S3 bucket exists:

```bash
aws s3 ls | grep <S3_BUCKET_NAME>
```

To check if the DynamoDB table exists:

```bash
aws dynamodb describe-table --table-name <DYNAMODB_TABLE_NAME>
```

## Terraform Backend Configuration
Ensure your `backend` block in the Terraform configuration (`backend.tf` or `main.tf`) includes:

```hcl
terraform {
  backend "s3" {
    bucket         = "<S3_BUCKET_NAME>"
    key            = "<STATE_FILE_PATH>"
    region         = "<AWS_REGION>"
    dynamodb_table = "<DYNAMODB_TABLE_NAME>"
  }
}
```

Now you can initialize Terraform using:

```bash
terraform init
```

This will configure Terraform to use the remote backend for storing state.

---

This README ensures proper setup and configuration of the remote state for your VPC module.

