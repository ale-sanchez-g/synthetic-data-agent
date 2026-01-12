# Resource Naming Conventions

**Version:** 1.0  
**Last Updated:** January 12, 2026  
**Status:** Approved

## Overview

This document defines the naming conventions for all AWS resources in the Synthetic Data Generator Agent project. Consistent naming improves resource discovery, management, and cost allocation.

---

## General Naming Pattern

### Standard Format

```
{project}-{domain}-{resource-type}-{environment}-{region}-{description}
```

### Components

| Component | Description | Examples | Required |
|-----------|-------------|----------|----------|
| project | Project identifier | `sdga` (Synthetic Data Generator Agent) | Yes |
| domain | Bounded context or domain | `datagen`, `schema`, `quality`, `infra` | Yes |
| resource-type | AWS resource type abbreviation | `lambda`, `s3`, `ddb`, `role` | Yes |
| environment | Deployment environment | `dev`, `stg`, `prod` | Yes |
| region | AWS region code | `us-east-1`, `eu-west-1` | Conditional* |
| description | Specific resource purpose | `generate-data`, `validation` | Yes |

*Region is included only for global resources or multi-region deployments

---

## Naming Rules

### Character Constraints

1. **Lowercase Only:** Use lowercase letters for consistency
2. **Separators:** Use hyphens (`-`) for readability
3. **No Spaces:** Never use spaces in resource names
4. **Alphanumeric:** Stick to alphanumeric characters and hyphens
5. **Length Limits:** Respect AWS service-specific length limits

### Best Practices

1. **Be Descriptive:** Names should clearly indicate the resource's purpose
2. **Be Consistent:** Follow the pattern across all resources
3. **Avoid Redundancy:** Don't repeat information (e.g., `s3-bucket-bucket`)
4. **Use Abbreviations:** Keep names concise but understandable
5. **Version When Needed:** Add version suffix for versioned resources (`-v1`, `-v2`)

---

## Domain Abbreviations

| Full Name | Abbreviation | Usage |
|-----------|--------------|-------|
| Data Generation | `datagen` | Resources related to synthetic data generation |
| Schema Management | `schema` | Resources for schema validation and templates |
| Quality Assurance | `quality` | Resources for quality metrics and validation |
| Infrastructure | `infra` | Shared infrastructure resources |
| Monitoring | `monitor` | Observability and monitoring resources |
| Security | `security` | Security-related resources |

---

## AWS Resource Type Abbreviations

### Compute

| Service | Abbreviation | Example |
|---------|--------------|---------|
| Lambda Function | `lambda` | `sdga-datagen-lambda-dev-generate` |
| Lambda Layer | `layer` | `sdga-datagen-layer-dev-faker` |

### Storage

| Service | Abbreviation | Example |
|---------|--------------|---------|
| S3 Bucket | `s3` | `sdga-datagen-s3-dev-generated-data` |
| DynamoDB Table | `ddb` | `sdga-datagen-ddb-dev-generations` |

### AI/ML

| Service | Abbreviation | Example |
|---------|--------------|---------|
| Bedrock Agent | `agent` | `sdga-datagen-agent-dev` |
| Bedrock Knowledge Base | `kb` | `sdga-schema-kb-dev` |
| OpenSearch Collection | `os` | `sdga-schema-os-dev-vectors` |

### Security

| Service | Abbreviation | Example |
|---------|--------------|---------|
| IAM Role | `role` | `sdga-datagen-role-dev-lambda-exec` |
| IAM Policy | `policy` | `sdga-datagen-policy-dev-s3-access` |
| KMS Key | `kms` | `sdga-infra-kms-dev-storage` |
| Security Group | `sg` | `sdga-infra-sg-dev-lambda` |

### Networking

| Service | Abbreviation | Example |
|---------|--------------|---------|
| VPC | `vpc` | `sdga-infra-vpc-dev` |
| Subnet | `subnet` | `sdga-infra-subnet-dev-private-1a` |
| NAT Gateway | `nat` | `sdga-infra-nat-dev-1a` |
| VPC Endpoint | `vpce` | `sdga-infra-vpce-dev-s3` |

### Monitoring

| Service | Abbreviation | Example |
|---------|--------------|---------|
| CloudWatch Log Group | `log` | `sdga-datagen-log-dev-lambda-generate` |
| CloudWatch Alarm | `alarm` | `sdga-datagen-alarm-dev-lambda-errors` |
| CloudWatch Dashboard | `dashboard` | `sdga-monitor-dashboard-dev` |
| SNS Topic | `sns` | `sdga-monitor-sns-dev-alarms` |

---

## Resource-Specific Naming

### 1. Lambda Functions

**Pattern:**
```
sdga-{domain}-lambda-{environment}-{function-name}
```

**Examples:**
```
sdga-datagen-lambda-dev-generate-data
sdga-schema-lambda-dev-validate
sdga-quality-lambda-dev-calculate-metrics
```

**Function Name Guidelines:**
- Use verb-noun pattern (e.g., `generate-data`, `validate-schema`)
- Maximum 64 characters
- Describe the primary action

---

### 2. S3 Buckets

**Pattern:**
```
sdga-{domain}-s3-{environment}-{purpose}
```

**Examples:**
```
sdga-datagen-s3-dev-generated-data
sdga-schema-s3-dev-knowledge-base
sdga-infra-s3-dev-terraform-state
sdga-monitor-s3-dev-logs
```

**Bucket Naming Rules:**
- Must be globally unique
- 3-63 characters
- No uppercase letters
- No underscores
- Must start and end with letter or number

**Important:** Append AWS account ID for uniqueness if needed:
```
sdga-datagen-s3-dev-generated-data-123456789012
```

---

### 3. DynamoDB Tables

**Pattern:**
```
sdga-{domain}-ddb-{environment}-{table-name}
```

**Examples:**
```
sdga-datagen-ddb-dev-generations
sdga-datagen-ddb-dev-generation-metadata
sdga-infra-ddb-dev-terraform-locks
```

**GSI Naming Pattern:**
```
{attribute1}-{attribute2}-index
```

**Examples:**
```
status-timestamp-index
user-timestamp-index
schema-digest-index
```

---

### 4. IAM Roles

**Pattern:**
```
sdga-{domain}-role-{environment}-{service}-{purpose}
```

**Examples:**
```
sdga-datagen-role-dev-lambda-generate
sdga-datagen-role-dev-bedrock-agent
sdga-schema-role-dev-knowledge-base
sdga-infra-role-dev-terraform-deploy
```

**Trust Policy Indicator:**
Include the trusted service in the name for clarity.

---

### 5. IAM Policies

**Pattern:**
```
sdga-{domain}-policy-{environment}-{access-type}
```

**Examples:**
```
sdga-datagen-policy-dev-s3-write
sdga-datagen-policy-dev-ddb-read-write
sdga-schema-policy-dev-opensearch-access
```

**Policy Type Guidelines:**
- `read`: Read-only access
- `write`: Write access (implies read)
- `admin`: Full administrative access
- `exec`: Execution permissions

---

### 6. KMS Keys

**Pattern:**
```
sdga-{domain}-kms-{environment}-{purpose}
```

**Alias Pattern:**
```
alias/sdga-{domain}-{environment}-{purpose}
```

**Examples:**
```
Key: sdga-infra-kms-dev-storage
Alias: alias/sdga-infra-dev-storage

Key: sdga-datagen-kms-dev-data-encryption
Alias: alias/sdga-datagen-dev-data-encryption
```

---

### 7. CloudWatch Log Groups

**Pattern:**
```
/aws/{service}/sdga-{domain}-{environment}-{resource}
```

**Examples:**
```
/aws/lambda/sdga-datagen-dev-generate-data
/aws/bedrock/agent/sdga-datagen-dev-agent
/aws/opensearch/sdga-schema-dev-vectors
```

**Retention Prefix:**
Use tags instead of name modifications for retention policies.

---

### 8. Bedrock Resources

#### Bedrock Agent

**Pattern:**
```
sdga-{domain}-agent-{environment}
```

**Example:**
```
sdga-datagen-agent-dev
```

#### Knowledge Base

**Pattern:**
```
sdga-{domain}-kb-{environment}
```

**Example:**
```
sdga-schema-kb-dev
```

#### Action Group

**Pattern:**
```
{domain}-{action-type}-actions
```

**Example:**
```
datagen-generation-actions
schema-validation-actions
quality-metrics-actions
```

---

### 9. OpenSearch Serverless

**Pattern:**
```
sdga-{domain}-os-{environment}-{purpose}
```

**Examples:**
```
sdga-schema-os-dev-vectors
sdga-schema-os-prod-vectors
```

**Index Pattern:**
```
{domain}-{entity}-{version}
```

**Examples:**
```
schema-templates-v1
datagen-patterns-v1
```

---

### 10. VPC Resources

#### VPC

**Pattern:**
```
sdga-infra-vpc-{environment}
```

**Example:**
```
sdga-infra-vpc-dev
```

#### Subnets

**Pattern:**
```
sdga-infra-subnet-{environment}-{type}-{az}
```

**Examples:**
```
sdga-infra-subnet-dev-public-1a
sdga-infra-subnet-dev-private-1b
sdga-infra-subnet-dev-data-1c
```

**Subnet Types:**
- `public`: Public subnets with IGW route
- `private`: Private subnets with NAT route
- `data`: Data tier subnets (no internet)

#### Security Groups

**Pattern:**
```
sdga-{domain}-sg-{environment}-{purpose}
```

**Examples:**
```
sdga-datagen-sg-dev-lambda
sdga-infra-sg-dev-vpc-endpoints
```

---

### 11. CloudWatch Resources

#### Alarms

**Pattern:**
```
sdga-{domain}-alarm-{environment}-{resource}-{metric}
```

**Examples:**
```
sdga-datagen-alarm-dev-lambda-errors
sdga-datagen-alarm-dev-ddb-throttles
sdga-quality-alarm-dev-lambda-duration
```

#### Dashboards

**Pattern:**
```
sdga-{domain}-dashboard-{environment}
```

**Examples:**
```
sdga-datagen-dashboard-dev
sdga-monitor-dashboard-dev-overview
```

#### SNS Topics

**Pattern:**
```
sdga-{domain}-sns-{environment}-{notification-type}
```

**Examples:**
```
sdga-monitor-sns-dev-alarms
sdga-datagen-sns-dev-generation-complete
```

---

## Tags

### Required Tags

All resources must include the following tags:

| Tag Key | Description | Example Values |
|---------|-------------|----------------|
| `Project` | Project name | `Synthetic Data Generator Agent` |
| `Environment` | Deployment environment | `dev`, `staging`, `production` |
| `ManagedBy` | Management tool | `Terraform`, `Manual` |
| `Owner` | Team or individual owner | `data-platform-team` |
| `CostCenter` | Cost allocation | `engineering`, `research` |
| `Domain` | Domain or bounded context | `datagen`, `schema`, `quality` |

### Optional Tags

| Tag Key | Description | Example Values |
|---------|-------------|----------------|
| `Compliance` | Compliance requirements | `HIPAA`, `GDPR`, `PCI-DSS` |
| `BackupPolicy` | Backup retention policy | `daily`, `weekly`, `none` |
| `DataClassification` | Data sensitivity level | `public`, `internal`, `confidential` |
| `Version` | Resource version | `v1`, `v2` |
| `Component` | Technical component | `api`, `batch`, `storage` |

### Tag Format

```hcl
tags = {
  Project            = "Synthetic Data Generator Agent"
  Environment        = "dev"
  ManagedBy          = "Terraform"
  Owner              = "data-platform-team"
  CostCenter         = "engineering"
  Domain             = "datagen"
  DataClassification = "internal"
  BackupPolicy       = "daily"
}
```

---

## Environment Naming

### Environment Codes

| Environment | Code | Purpose |
|-------------|------|---------|
| Development | `dev` | Development and testing |
| Staging | `stg` | Pre-production validation |
| Production | `prod` | Production workloads |
| Sandbox | `sbx` | Experimentation (optional) |
| DR | `dr` | Disaster recovery (optional) |

### Multi-Region Naming

For multi-region deployments, include region code:

```
sdga-datagen-s3-prod-us-east-1-generated-data
sdga-datagen-s3-prod-eu-west-1-generated-data
```

---

## Terraform Resource Names

### Resource Naming in Terraform

Use descriptive Terraform resource names that reflect the actual AWS resource:

**Pattern:**
```hcl
resource "aws_lambda_function" "{domain}_{function_name}_{environment}" {
  function_name = "sdga-datagen-lambda-${var.environment}-generate-data"
}
```

**Examples:**
```hcl
# Good
resource "aws_lambda_function" "datagen_generate_data_dev" {
  function_name = "sdga-datagen-lambda-dev-generate-data"
}

# Good
resource "aws_iam_role" "datagen_lambda_exec_dev" {
  name = "sdga-datagen-role-dev-lambda-generate"
}

# Avoid
resource "aws_lambda_function" "function1" {
  function_name = "my-function"
}
```

---

## Module Naming

### Terraform Module Directory Structure

```
modules/
├── bedrock-agent/
├── bedrock-knowledge-base/
├── lambda/
├── lambda-layers/
├── s3/
├── dynamodb/
├── opensearch/
├── iam/
├── kms/
├── vpc/
├── cloudwatch/
└── waf/
```

### Module Resource Prefixes

Within modules, use local variables for consistent naming:

```hcl
locals {
  resource_prefix = "${var.project}-${var.domain}-${var.environment}"
  
  lambda_name = "${local.resource_prefix}-lambda-${var.function_name}"
  role_name   = "${local.resource_prefix}-role-lambda-${var.function_name}"
}
```

---

## File Naming Conventions

### Terraform Files

| File | Purpose |
|------|---------|
| `main.tf` | Primary resource definitions |
| `variables.tf` | Input variable declarations |
| `outputs.tf` | Output value definitions |
| `versions.tf` | Provider version constraints |
| `backend.tf` | Backend configuration |
| `locals.tf` | Local value definitions |
| `data.tf` | Data source queries |
| `iam.tf` | IAM role and policy definitions |

### Script Files

**Pattern:**
```
{action}-{resource}.sh
```

**Examples:**
```
deploy-infrastructure.sh
build-lambda-layers.sh
validate-terraform.sh
```

---

## Documentation Files

**Pattern:**
```
{topic}.md
```

**Examples:**
```
architecture.md
naming-conventions.md
security-requirements.md
environment-strategy.md
cost-estimates.md
```

---

## Examples by Environment

### Development Environment

```
# Lambda Functions
sdga-datagen-lambda-dev-generate-data
sdga-schema-lambda-dev-validate

# S3 Buckets
sdga-datagen-s3-dev-generated-data-123456789012
sdga-schema-s3-dev-knowledge-base-123456789012

# DynamoDB Tables
sdga-datagen-ddb-dev-generations

# IAM Roles
sdga-datagen-role-dev-lambda-generate
sdga-datagen-role-dev-bedrock-agent

# KMS Keys
alias/sdga-infra-dev-storage

# Log Groups
/aws/lambda/sdga-datagen-dev-generate-data
/aws/bedrock/agent/sdga-datagen-dev-agent
```

### Production Environment

```
# Lambda Functions
sdga-datagen-lambda-prod-generate-data
sdga-schema-lambda-prod-validate

# S3 Buckets
sdga-datagen-s3-prod-generated-data-123456789012
sdga-schema-s3-prod-knowledge-base-123456789012

# DynamoDB Tables
sdga-datagen-ddb-prod-generations

# IAM Roles
sdga-datagen-role-prod-lambda-generate
sdga-datagen-role-prod-bedrock-agent

# KMS Keys
alias/sdga-infra-prod-storage

# Log Groups
/aws/lambda/sdga-datagen-prod-generate-data
/aws/bedrock/agent/sdga-datagen-prod-agent
```

---

## Validation Checklist

Before creating any resource, verify:

- [ ] Name follows the established pattern
- [ ] Environment code is included
- [ ] Domain is clearly identified
- [ ] Resource type abbreviation is correct
- [ ] Name is descriptive and unambiguous
- [ ] Length is within AWS service limits
- [ ] All required tags are included
- [ ] Name uses lowercase and hyphens only
- [ ] Global uniqueness for S3 buckets

---

## Exceptions

Document any deviations from these conventions:

| Resource | Deviation | Reason | Approved By | Date |
|----------|-----------|--------|-------------|------|
| - | - | - | - | - |

---

## References

- [AWS Resource Naming Best Practices](https://docs.aws.amazon.com/whitepapers/latest/tagging-best-practices/)
- [Terraform Naming Conventions](https://www.terraform-best-practices.com/naming)
- [AWS Service Naming Limits](https://docs.aws.amazon.com/general/latest/gr/aws-service-information.html)

---

**Document Owner:** Infrastructure Team  
**Approved By:** Technical Lead  
**Review Cycle:** Quarterly  
**Next Review:** April 2026
