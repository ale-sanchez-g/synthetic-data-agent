# Terraform Project - Synthetic Data Generator Agent

This directory contains the Terraform infrastructure as code (IaC) for the Synthetic Data Generator Agent project. The infrastructure is organized in a modular structure with support for multiple environments (dev, stg, prod).

## 📁 Project Structure

```
terraform/
├── backend.tf                 # Backend configuration (S3 + DynamoDB)
├── main.tf                    # Main orchestration with module calls
├── outputs.tf                 # Output values
├── variables.tf               # Input variable definitions
├── versions.tf                # Provider and version constraints
│
├── backend-configs/           # Backend configuration per environment
│   ├── backend-dev.hcl
│   ├── backend-stg.hcl
│   └── backend-prod.hcl
│
├── environments/              # Environment-specific variable files
│   ├── dev.tfvars            # Development configuration
│   ├── stg.tfvars            # Staging configuration
│   └── prod.tfvars           # Production configuration
│
├── modules/                   # Reusable Terraform modules
│   ├── bedrock-agent/        # Bedrock Agent and action groups
│   ├── bedrock-knowledge-base/  # Knowledge Base with OpenSearch
│   ├── cloudwatch/           # CloudWatch logs, metrics, alarms
│   ├── dynamodb/             # DynamoDB table for generation history
│   ├── iam/                  # IAM roles and policies
│   ├── kms/                  # KMS keys for encryption
│   ├── lambda/               # Lambda functions
│   ├── lambda-layers/        # Lambda layers for dependencies
│   ├── opensearch/           # OpenSearch Serverless collection
│   ├── s3/                   # S3 buckets for data storage
│   ├── vpc/                  # VPC and networking
│   └── waf/                  # WAF web ACL
│
└── scripts/                   # Helper scripts
    ├── setup-backend.sh      # Create S3 bucket and DynamoDB table
    ├── init.sh               # Initialize Terraform
    ├── plan.sh               # Run terraform plan
    ├── deploy.sh             # Apply terraform changes
    ├── validate.sh           # Validate configuration
    └── destroy.sh            # Destroy infrastructure
```

## 🚀 Getting Started

### Prerequisites

- **Terraform**: Version 1.6.0 or higher
- **AWS CLI**: Configured with appropriate credentials
- **IAM Permissions**: Administrator access or equivalent permissions to create resources

### Initial Setup

1. **Set up the backend infrastructure** (one-time per environment):

```bash
# For development
./scripts/setup-backend.sh dev

# For staging
./scripts/setup-backend.sh stg

# For production
./scripts/setup-backend.sh prod
```

This creates:
- S3 bucket for Terraform state storage
- DynamoDB table for state locking
- KMS key for encryption

2. **Initialize Terraform**:

```bash
# For development
./scripts/init.sh dev

# For staging
./scripts/init.sh stg

# For production
./scripts/init.sh prod
```

3. **Validate the configuration**:

```bash
./scripts/validate.sh
```

## 📋 Deployment Workflow

### Development Environment

```bash
# 1. Plan changes
./scripts/plan.sh dev

# 2. Review the plan output

# 3. Apply changes
./scripts/deploy.sh dev
```

### Staging Environment

```bash
# 1. Plan changes
./scripts/plan.sh stg

# 2. Review the plan output

# 3. Apply changes (requires confirmation)
./scripts/deploy.sh stg
```

### Production Environment

```bash
# 1. Plan changes
./scripts/plan.sh prod

# 2. Review the plan output carefully

# 3. Apply changes (requires additional confirmation)
./scripts/deploy.sh prod
```

## 🏗️ Module Overview

### Core Modules

| Module | Description | Key Resources |
|--------|-------------|---------------|
| **bedrock-agent** | Bedrock Agent with Claude 3 Sonnet | Agent, Alias, Action Groups |
| **bedrock-knowledge-base** | Knowledge Base with RAG | Knowledge Base, Data Source |
| **lambda** | Three action functions | generate_synthetic_data, validate_schema, calculate_quality_metrics |
| **lambda-layers** | Shared dependencies | boto3, faker, mimesis, jsonschema, pydantic |
| **iam** | IAM roles and policies | Bedrock Agent role, Lambda role, KB role |
| **s3** | Data storage buckets | Generated data bucket, KB bucket |
| **dynamodb** | Generation history | Table with GSIs, TTL enabled |
| **opensearch** | Vector database | Serverless collection for embeddings |
| **kms** | Encryption keys | Customer-managed keys with rotation |
| **vpc** | Network isolation | VPC, subnets, endpoints (stg/prod only) |
| **cloudwatch** | Observability | Log groups, alarms, dashboard |
| **waf** | Web application firewall | Rate limiting, IP filtering (stg/prod only) |

## 🔧 Environment Configuration

### Development (dev)

- **Purpose**: Development and testing
- **Cost**: ~$182.50/month
- **Features**:
  - Lambda: 1024 MB memory, 5 concurrent executions
  - OpenSearch: 2 OCU
  - CloudWatch: 7-day retention
  - VPC: Disabled
  - KMS: Disabled (AWS managed keys)
  - WAF: Disabled

### Staging (stg)

- **Purpose**: Pre-production validation
- **Cost**: ~$467/month
- **Features**:
  - Lambda: 1536 MB memory, 10 concurrent executions
  - OpenSearch: 4 OCU
  - CloudWatch: 30-day retention
  - VPC: Enabled
  - KMS: Enabled with rotation
  - WAF: Enabled
  - Security: GuardDuty, Security Hub, Config

### Production (prod)

- **Purpose**: Live production workloads
- **Cost**: ~$1,847/month
- **Features**:
  - Lambda: 2048 MB memory, 50 concurrent executions
  - OpenSearch: 8 OCU
  - CloudWatch: 90-day retention
  - VPC: Enabled with 3 AZs
  - KMS: Enabled with rotation
  - WAF: Enabled
  - Security: Full compliance stack
  - S3: Cross-region replication, MFA delete

## 📊 Resource Naming Convention

All resources follow the pattern:
```
{project}-{domain}-{resource-type}-{environment}-{description}
```

Example:
- `sdga-datagen-agent-prod` (Bedrock Agent)
- `sdga-datagen-lambda-prod-generate` (Lambda function)
- `sdga-datagen-s3-prod-data` (S3 bucket)

## 🔐 Security Best Practices

1. **State Security**:
   - State files encrypted at rest in S3
   - State locking with DynamoDB
   - Versioning enabled for recovery

2. **Access Control**:
   - Least privilege IAM policies
   - Service-specific roles
   - No public internet access to resources

3. **Data Protection**:
   - KMS encryption for all data at rest
   - TLS 1.2+ for data in transit
   - S3 versioning and lifecycle policies

4. **Monitoring**:
   - CloudTrail for API auditing
   - GuardDuty for threat detection
   - Security Hub for compliance
   - Config for resource tracking

## 📝 Making Changes

### Adding a New Module

1. Create module directory: `modules/<module-name>/`
2. Add `main.tf`, `variables.tf`, `outputs.tf`
3. Reference module in root `main.tf`
4. Update environment `.tfvars` files as needed

### Modifying Existing Resources

1. Update module or root configuration files
2. Run `./scripts/validate.sh` to check syntax
3. Run `./scripts/plan.sh <env>` to preview changes
4. Review the plan carefully
5. Apply with `./scripts/deploy.sh <env>`

### Testing Changes

1. Always test in `dev` environment first
2. Validate in `stg` before production deployment
3. Use feature flags where possible
4. Keep changes small and incremental

## 🔄 State Management

### Viewing Current State

```bash
terraform state list
terraform state show <resource>
```

### Moving Resources

```bash
terraform state mv <source> <destination>
```

### Removing Resources from State

```bash
terraform state rm <resource>
```

### Importing Existing Resources

```bash
terraform import <resource> <aws-resource-id>
```

## 🧪 Validation and Testing

### Format Check

```bash
terraform fmt -check -recursive
```

### Configuration Validation

```bash
terraform validate
```

### Cost Estimation

```bash
# Using Infracost (if installed)
infracost breakdown --path .
```

### Security Scanning

```bash
# Using tfsec (if installed)
tfsec .

# Using Checkov (if installed)
checkov -d .
```

## 🚨 Troubleshooting

### Backend Initialization Issues

```bash
# Reconfigure backend
terraform init -reconfigure -backend-config=backend-configs/backend-<env>.hcl
```

### State Lock Issues

```bash
# Force unlock (use with caution)
terraform force-unlock <lock-id>
```

### Provider Issues

```bash
# Upgrade providers
terraform init -upgrade
```

### Module Issues

```bash
# Get latest modules
terraform get -update
```

## 📦 Outputs

After successful deployment, Terraform outputs:

- Bedrock Agent ID and ARN
- Lambda function names and ARNs
- S3 bucket names
- DynamoDB table name
- IAM role ARNs
- KMS key IDs
- VPC and subnet IDs (if enabled)
- CloudWatch log group names
- Usage instructions

View outputs:
```bash
terraform output
terraform output -json  # JSON format
```

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
- name: Setup Backend
  run: ./scripts/setup-backend.sh ${{ env.ENVIRONMENT }}

- name: Terraform Init
  run: ./scripts/init.sh ${{ env.ENVIRONMENT }}

- name: Terraform Plan
  run: ./scripts/plan.sh ${{ env.ENVIRONMENT }}

- name: Terraform Apply
  run: ./scripts/deploy.sh ${{ env.ENVIRONMENT }}
```

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)
- [Project Architecture Docs](../docs/architecture.md)
- [Security Requirements](../docs/security-requirements.md)
- [Environment Strategy](../docs/environment-strategy.md)
- [Cost Estimates](../docs/cost-estimates.md)

## ⚠️ Important Notes

1. **Never commit** `.tfstate` files or sensitive variables to version control
2. **Always review** plan output before applying changes
3. **Test in dev** environment before deploying to production
4. **Backup state files** regularly (S3 versioning handles this)
5. **Document changes** in commit messages and pull requests
6. **Follow naming conventions** for consistency
7. **Tag all resources** appropriately for cost tracking

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Run validation: `./scripts/validate.sh`
4. Test in dev: `./scripts/plan.sh dev`
5. Submit pull request with plan output
6. Get approval from infrastructure team
7. Deploy after merge

## 📞 Support

For questions or issues:
- Review documentation in `../docs/`
- Check troubleshooting section above
- Contact infrastructure team
- Create GitHub issue for bugs

---

**Last Updated**: 2024
**Terraform Version**: 1.6.0+
**AWS Provider Version**: 5.0+
