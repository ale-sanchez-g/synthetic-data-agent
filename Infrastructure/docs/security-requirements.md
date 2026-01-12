# Security Requirements and Compliance

**Version:** 1.0  
**Last Updated:** January 12, 2026  
**Status:** Approved

## Overview

This document defines the security requirements, compliance standards, and security controls for the Synthetic Data Generator Agent. All components must adhere to these requirements to ensure data protection, regulatory compliance, and system integrity.

---

## Table of Contents

1. [Security Principles](#security-principles)
2. [Authentication and Authorization](#authentication-and-authorization)
3. [Data Protection](#data-protection)
4. [Network Security](#network-security)
5. [Compliance Requirements](#compliance-requirements)
6. [Security Monitoring](#security-monitoring)
7. [Incident Response](#incident-response)
8. [Security Controls Matrix](#security-controls-matrix)

---

## Security Principles

### Core Principles

1. **Defense in Depth:** Multiple layers of security controls
2. **Least Privilege:** Minimum necessary permissions for all entities
3. **Zero Trust:** Never trust, always verify
4. **Security by Design:** Security integrated from the start
5. **Fail Secure:** System defaults to secure state on failure
6. **Audit Everything:** Comprehensive logging of all actions

### AWS Well-Architected Framework - Security Pillar

Our implementation aligns with AWS Security Pillar best practices:

- **Identity and Access Management:** Strong IAM policies and roles
- **Detective Controls:** Logging, monitoring, and alerting
- **Infrastructure Protection:** VPC, security groups, network ACLs
- **Data Protection:** Encryption at rest and in transit
- **Incident Response:** Automated response and recovery procedures

---

## Authentication and Authorization

### IAM Roles and Policies

#### Principle of Least Privilege

All IAM roles must:
- Grant only permissions required for the specific function
- Use explicit deny for sensitive actions
- Include condition keys to limit scope
- Be reviewed quarterly for excessive permissions

#### IAM Role Requirements

##### Bedrock Agent Role

**Permissions:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "arn:aws:lambda:*:*:function:sdga-datagen-lambda-*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:RetrieveAndGenerate",
        "bedrock:Retrieve"
      ],
      "Resource": [
        "arn:aws:bedrock:*:*:knowledge-base/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:log-group:/aws/bedrock/agent/*"
      ]
    }
  ]
}
```

**Trust Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${AWS_ACCOUNT_ID}"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:bedrock:*:${AWS_ACCOUNT_ID}:agent/*"
        }
      }
    }
  ]
}
```

##### Lambda Execution Roles

**Generate Data Function Role:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::sdga-datagen-s3-*-generated-data-*/*"
      ],
      "Condition": {
        "StringEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": [
        "arn:aws:dynamodb:*:*:table/sdga-datagen-ddb-*-generations"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": [
        "arn:aws:kms:*:*:key/*"
      ],
      "Condition": {
        "StringEquals": {
          "kms:ViaService": [
            "s3.*.amazonaws.com",
            "dynamodb.*.amazonaws.com"
          ]
        }
      }
    }
  ]
}
```

**Validate Schema Function Role:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:log-group:/aws/lambda/sdga-schema-lambda-*"
      ]
    }
  ]
}
```

**Calculate Quality Metrics Function Role:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::sdga-datagen-s3-*-generated-data-*/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::sdga-datagen-s3-*-generated-data-*/*/quality_report.json"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": [
        "arn:aws:kms:*:*:key/*"
      ]
    }
  ]
}
```

##### Knowledge Base Role

**Permissions:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::sdga-schema-s3-*-knowledge-base-*",
        "arn:aws:s3:::sdga-schema-s3-*-knowledge-base-*/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "aoss:APIAccessAll"
      ],
      "Resource": [
        "arn:aws:aoss:*:*:collection/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel"
      ],
      "Resource": [
        "arn:aws:bedrock:*::foundation-model/amazon.titan-embed-text-v1"
      ]
    }
  ]
}
```

### Service Control Policies (SCPs)

For multi-account setups, implement SCPs to:
- Prevent deletion of CloudTrail logs
- Enforce encryption requirements
- Restrict resource creation to approved regions
- Prevent privilege escalation

---

## Data Protection

### Encryption Requirements

#### Encryption at Rest

**Mandatory Encryption:**

| Service | Encryption Method | Key Management |
|---------|------------------|----------------|
| S3 | SSE-KMS | Customer Managed CMK |
| DynamoDB | KMS | Customer Managed CMK |
| CloudWatch Logs | KMS | Customer Managed CMK |
| OpenSearch | Service-managed | AWS managed |
| Lambda Environment Variables | KMS | Customer Managed CMK |
| EBS (if used) | KMS | Customer Managed CMK |

**KMS Key Configuration:**
```hcl
resource "aws_kms_key" "storage_key" {
  description             = "KMS key for storage encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow services to use the key"
        Effect = "Allow"
        Principal = {
          Service = [
            "s3.amazonaws.com",
            "dynamodb.amazonaws.com",
            "logs.amazonaws.com"
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = [
              "s3.${data.aws_region.current.name}.amazonaws.com",
              "dynamodb.${data.aws_region.current.name}.amazonaws.com",
              "logs.${data.aws_region.current.name}.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
  
  tags = {
    Project     = "Synthetic Data Generator Agent"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "storage_key_alias" {
  name          = "alias/sdga-infra-${var.environment}-storage"
  target_key_id = aws_kms_key.storage_key.key_id
}
```

**Key Rotation:**
- Automatic rotation enabled (annual)
- Manual rotation process documented
- Old keys retained for decryption

#### Encryption in Transit

**Requirements:**
- TLS 1.2 or higher for all communications
- Certificate validation enabled
- Strong cipher suites only

**S3 Bucket Policy - Enforce TLS:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUnencryptedConnections",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::sdga-datagen-s3-*-generated-data-*",
        "arn:aws:s3:::sdga-datagen-s3-*-generated-data-*/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Sid": "DenyUnencryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::sdga-datagen-s3-*-generated-data-*/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    }
  ]
}
```

### Data Classification

| Classification | Description | Examples | Handling Requirements |
|----------------|-------------|----------|----------------------|
| **Public** | Publicly available | Documentation, marketing | Standard encryption |
| **Internal** | Business use only | Schemas, templates | Encryption, access control |
| **Confidential** | Sensitive business data | Customer patterns | Strong encryption, audit logging |
| **Restricted** | Highly sensitive | Compliance data | KMS, restricted access, full audit |

**Tagging Requirement:**
All data storage resources must include `DataClassification` tag.

### Data Retention and Deletion

#### S3 Lifecycle Policies

**Generated Data Bucket:**
```hcl
resource "aws_s3_bucket_lifecycle_configuration" "generated_data" {
  bucket = aws_s3_bucket.generated_data.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 180
      storage_class = "GLACIER_IR"
    }

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
```

#### DynamoDB TTL

**Generation History Table:**
```hcl
resource "aws_dynamodb_table" "generations" {
  # ... other configuration ...

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}
```

**TTL Calculation:**
```python
import time

# Set TTL to 90 days from creation
ttl_seconds = int(time.time()) + (90 * 24 * 60 * 60)
```

### Sensitive Data Handling

**Prohibited Actions:**
1. Storing credentials in code or environment variables (use Secrets Manager)
2. Logging sensitive data
3. Transmitting data over unencrypted connections
4. Storing sensitive data in CloudWatch Logs

**Secrets Management:**
```hcl
resource "aws_secretsmanager_secret" "api_keys" {
  name = "sdga-infra-secret-${var.environment}-api-keys"
  
  kms_key_id = aws_kms_key.secrets_key.id
  
  recovery_window_in_days = 30
}
```

**Lambda Access to Secrets:**
```python
import boto3
import json
from botocore.exceptions import ClientError

def get_secret(secret_name):
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager')
    
    try:
        response = client.get_secret_value(SecretId=secret_name)
        return json.loads(response['SecretString'])
    except ClientError as e:
        raise Exception(f"Error retrieving secret: {e}")
```

---

## Network Security

### VPC Configuration (Optional)

**VPC Design:**
```
VPC: 10.0.0.0/16
├── Public Subnets (for NAT Gateways)
│   ├── 10.0.1.0/24 (us-east-1a)
│   ├── 10.0.2.0/24 (us-east-1b)
│   └── 10.0.3.0/24 (us-east-1c)
├── Private Subnets (for Lambda)
│   ├── 10.0.11.0/24 (us-east-1a)
│   ├── 10.0.12.0/24 (us-east-1b)
│   └── 10.0.13.0/24 (us-east-1c)
└── Data Subnets (for data stores)
    ├── 10.0.21.0/24 (us-east-1a)
    ├── 10.0.22.0/24 (us-east-1b)
    └── 10.0.23.0/24 (us-east-1c)
```

### Security Groups

**Lambda Security Group:**
```hcl
resource "aws_security_group" "lambda" {
  name_prefix = "sdga-datagen-sg-${var.environment}-lambda"
  vpc_id      = aws_vpc.main.id

  # Allow outbound HTTPS to AWS services
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS to AWS services"
  }

  # Deny all inbound by default
  tags = {
    Project     = "Synthetic Data Generator Agent"
    Environment = var.environment
  }
}
```

**VPC Endpoints Security Group:**
```hcl
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "sdga-infra-sg-${var.environment}-vpce"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda.id]
    description     = "HTTPS from Lambda functions"
  }

  tags = {
    Project     = "Synthetic Data Generator Agent"
    Environment = var.environment
  }
}
```

### VPC Endpoints

**Required Endpoints:**
- S3 (Gateway endpoint)
- DynamoDB (Gateway endpoint)
- Lambda (Interface endpoint)
- Bedrock Runtime (Interface endpoint)
- Secrets Manager (Interface endpoint)
- CloudWatch Logs (Interface endpoint)
- KMS (Interface endpoint)

**Example Configuration:**
```hcl
# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  
  route_table_ids = [
    aws_route_table.private.id,
    aws_route_table.data.id
  ]
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::sdga-*",
          "arn:aws:s3:::sdga-*/*"
        ]
      }
    ]
  })
}

# Bedrock Runtime Interface Endpoint
resource "aws_vpc_endpoint" "bedrock_runtime" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.bedrock-runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true
}
```

### Network ACLs

**Private Subnet NACL:**
```hcl
resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  # Allow inbound from VPC
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 0
    to_port    = 0
  }

  # Allow outbound HTTPS
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Allow outbound to VPC
  egress {
    protocol   = -1
    rule_no    = 110
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 0
    to_port    = 0
  }
}
```

### AWS WAF (Optional)

**Rate Limiting Rule:**
```hcl
resource "aws_wafv2_web_acl" "api_protection" {
  name  = "sdga-infra-waf-${var.environment}-api"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "rate-limit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "aws-managed-common-rules"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "aws-managed-common-rules"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "api-protection"
    sampled_requests_enabled   = true
  }
}
```

---

## Compliance Requirements

### GDPR (General Data Protection Regulation)

**Requirements:**
1. **Data Minimization:** Only generate necessary synthetic data
2. **Right to Erasure:** Implement data deletion mechanisms
3. **Data Portability:** Support multiple export formats
4. **Privacy by Design:** Security controls built-in from start
5. **Audit Trail:** Complete logging of data operations

**Implementation:**
- S3 lifecycle policies for automatic deletion
- DynamoDB TTL for record expiration
- CloudTrail logging enabled
- Data classification tags on all resources

### HIPAA (Health Insurance Portability and Accountability Act)

**Requirements:**
1. **Encryption:** All PHI encrypted at rest and in transit
2. **Access Controls:** Role-based access control implemented
3. **Audit Logging:** All access to PHI logged
4. **Backup and Recovery:** Regular backups with tested recovery
5. **Incident Response:** Documented breach notification process

**Implementation:**
- KMS encryption for all storage
- IAM roles with least privilege
- CloudWatch Logs with retention
- S3 versioning and cross-region replication
- Incident response runbooks

### PCI DSS (Payment Card Industry Data Security Standard)

**Requirements:**
1. **Network Segmentation:** Isolate cardholder data environment
2. **Strong Cryptography:** Industry-standard encryption
3. **Access Control:** Restrict access on need-to-know basis
4. **Monitoring:** Track and monitor all access
5. **Regular Testing:** Security testing and assessment

**Implementation:**
- VPC with private subnets
- TLS 1.2+ for all communications
- IAM policies with explicit permissions
- CloudWatch alarms and monitoring
- Automated security scanning

### SOC 2 Type II

**Requirements:**
1. **Security:** Protection against unauthorized access
2. **Availability:** System accessible as committed
3. **Processing Integrity:** System processing complete and accurate
4. **Confidentiality:** Confidential information protected
5. **Privacy:** Personal information handled properly

**Implementation:**
- Multi-AZ deployment for high availability
- Data validation in Lambda functions
- Encryption and access controls
- Privacy controls and data classification

---

## Security Monitoring

### CloudTrail

**Configuration:**
```hcl
resource "aws_cloudtrail" "main" {
  name                          = "sdga-infra-trail-${var.environment}"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.cloudtrail.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"
      values = [
        "arn:aws:s3:::sdga-datagen-s3-${var.environment}-generated-data-*/*"
      ]
    }

    data_resource {
      type = "AWS::Lambda::Function"
      values = ["arn:aws:lambda:*:*:function:sdga-*"]
    }
  }

  insight_selector {
    insight_type = "ApiCallRateInsight"
  }

  tags = {
    Project     = "Synthetic Data Generator Agent"
    Environment = var.environment
  }
}
```

### GuardDuty

**Enable GuardDuty:**
```hcl
resource "aws_guardduty_detector" "main" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = false
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = {
    Project     = "Synthetic Data Generator Agent"
    Environment = var.environment
  }
}
```

### AWS Config

**Required Config Rules:**
1. `s3-bucket-public-read-prohibited`
2. `s3-bucket-public-write-prohibited`
3. `s3-bucket-server-side-encryption-enabled`
4. `dynamodb-table-encrypted-kms`
5. `lambda-function-public-access-prohibited`
6. `iam-policy-no-statements-with-admin-access`
7. `cloudtrail-enabled`
8. `guardduty-enabled-centralized`

### Security Hub

**Enable Security Hub with standards:**
- AWS Foundational Security Best Practices
- CIS AWS Foundations Benchmark
- PCI DSS

```hcl
resource "aws_securityhub_account" "main" {}

resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
  depends_on    = [aws_securityhub_account.main]
}

resource "aws_securityhub_standards_subscription" "aws_foundational" {
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.main]
}
```

### CloudWatch Alarms

**Security-Related Alarms:**

```hcl
# Unauthorized API Calls
resource "aws_cloudwatch_log_metric_filter" "unauthorized_api" {
  name           = "UnauthorizedAPICalls"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"

  metric_transformation {
    name      = "UnauthorizedAPICalls"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api" {
  alarm_name          = "sdga-security-alarm-${var.environment}-unauthorized-api"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnauthorizedAPICalls"
  namespace           = "CloudTrailMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Triggers when unauthorized API calls detected"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
}

# Root Account Usage
resource "aws_cloudwatch_log_metric_filter" "root_usage" {
  name           = "RootAccountUsage"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"

  metric_transformation {
    name      = "RootAccountUsage"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

# IAM Policy Changes
resource "aws_cloudwatch_log_metric_filter" "iam_policy_changes" {
  name           = "IAMPolicyChanges"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = "{($.eventName=DeleteGroupPolicy)||($.eventName=DeleteRolePolicy)||($.eventName=DeleteUserPolicy)||($.eventName=PutGroupPolicy)||($.eventName=PutRolePolicy)||($.eventName=PutUserPolicy)||($.eventName=CreatePolicy)||($.eventName=DeletePolicy)||($.eventName=CreatePolicyVersion)||($.eventName=DeletePolicyVersion)||($.eventName=AttachRolePolicy)||($.eventName=DetachRolePolicy)||($.eventName=AttachUserPolicy)||($.eventName=DetachUserPolicy)||($.eventName=AttachGroupPolicy)||($.eventName=DetachGroupPolicy)}"

  metric_transformation {
    name      = "IAMPolicyChanges"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}
```

---

## Incident Response

### Incident Response Plan

#### Phase 1: Preparation
- Document incident response procedures
- Establish incident response team
- Configure monitoring and alerting
- Conduct regular security drills

#### Phase 2: Detection and Analysis
- Automated detection via GuardDuty, Security Hub
- CloudWatch alarms for anomalies
- Manual security reviews
- Threat intelligence integration

#### Phase 3: Containment
- Isolate affected resources
- Block malicious IPs via WAF/Security Groups
- Revoke compromised credentials
- Snapshot affected volumes for forensics

#### Phase 4: Eradication
- Remove malicious code or configurations
- Patch vulnerabilities
- Update security controls
- Review and update IAM policies

#### Phase 5: Recovery
- Restore from clean backups
- Redeploy infrastructure from Terraform
- Verify system integrity
- Resume normal operations

#### Phase 6: Post-Incident
- Document incident details
- Conduct lessons learned review
- Update security controls
- Update incident response procedures

### Automated Response Actions

**Lambda Function for Automated Response:**
```python
import boto3

def lambda_handler(event, context):
    """
    Automated response to security incidents
    """
    # Parse GuardDuty finding
    finding = event['detail']
    severity = finding['severity']
    finding_type = finding['type']
    
    if severity >= 7:  # High severity
        if 'UnauthorizedAccess' in finding_type:
            # Revoke credentials
            revoke_credentials(finding)
        
        elif 'Backdoor' in finding_type:
            # Isolate instance
            isolate_resource(finding)
        
        # Always notify security team
        notify_security_team(finding)
    
    return {'statusCode': 200}
```

### Security Runbooks

**Location:** `Infrastructure/runbooks/security/`

**Required Runbooks:**
1. `unauthorized-access-response.md`
2. `data-breach-response.md`
3. `credential-compromise-response.md`
4. `dos-attack-response.md`
5. `malware-detection-response.md`

---

## Security Controls Matrix

| Control Domain | Control | Implementation | Status | Priority |
|----------------|---------|----------------|--------|----------|
| **Identity & Access** | IAM Roles with Least Privilege | IAM policies per function | Required | High |
| **Identity & Access** | MFA for Human Users | AWS IAM MFA | Required | High |
| **Identity & Access** | Service Control Policies | AWS Organizations SCPs | Optional | Medium |
| **Data Protection** | Encryption at Rest | KMS for all storage | Required | High |
| **Data Protection** | Encryption in Transit | TLS 1.2+ | Required | High |
| **Data Protection** | Key Rotation | Annual automatic rotation | Required | High |
| **Data Protection** | Data Classification | Tags on all resources | Required | High |
| **Data Protection** | Backup & Recovery | S3 versioning, DDB PITR | Required | High |
| **Network Security** | VPC Isolation | Private subnets for Lambda | Optional | Medium |
| **Network Security** | Security Groups | Least privilege rules | Optional | Medium |
| **Network Security** | VPC Endpoints | For AWS services | Optional | Medium |
| **Network Security** | Network ACLs | Subnet-level filtering | Optional | Low |
| **Network Security** | AWS WAF | Rate limiting, IP filtering | Optional | Low |
| **Monitoring** | CloudTrail Logging | All API calls logged | Required | High |
| **Monitoring** | GuardDuty | Threat detection | Required | High |
| **Monitoring** | Security Hub | Compliance monitoring | Required | High |
| **Monitoring** | AWS Config | Resource compliance | Required | High |
| **Monitoring** | CloudWatch Alarms | Security event alerting | Required | High |
| **Compliance** | GDPR Controls | Data retention, deletion | Required | High |
| **Compliance** | HIPAA Controls | PHI encryption, audit | Conditional | High |
| **Compliance** | PCI DSS Controls | Cardholder data protection | Conditional | High |
| **Incident Response** | Automated Response | Lambda-based automation | Required | Medium |
| **Incident Response** | Runbooks | Documented procedures | Required | Medium |
| **Incident Response** | Security Drills | Quarterly testing | Required | Medium |

---

## Security Checklist

### Pre-Deployment Security Review

- [ ] All IAM roles follow least privilege
- [ ] Encryption enabled for all data at rest
- [ ] TLS enforced for all data in transit
- [ ] CloudTrail enabled and validated
- [ ] GuardDuty enabled
- [ ] Security Hub enabled with standards
- [ ] AWS Config rules configured
- [ ] CloudWatch alarms created
- [ ] KMS key rotation enabled
- [ ] S3 bucket policies enforce encryption
- [ ] DynamoDB encryption configured
- [ ] Lambda environment variables encrypted
- [ ] VPC endpoints configured (if using VPC)
- [ ] Security groups follow least privilege
- [ ] Backup and recovery tested
- [ ] Incident response plan documented
- [ ] Security runbooks created
- [ ] Compliance requirements met
- [ ] Data classification tags applied
- [ ] Secret Manager used for secrets

### Post-Deployment Security Validation

- [ ] Penetration testing completed
- [ ] Vulnerability scanning performed
- [ ] IAM policy effectiveness verified
- [ ] Encryption verified for all resources
- [ ] Logging and monitoring validated
- [ ] Incident response tested
- [ ] Compliance audit passed
- [ ] Performance impact assessed
- [ ] Cost optimization reviewed
- [ ] Documentation updated

---

## References

- [AWS Well-Architected Framework - Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html)
- [AWS Security Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
- [GDPR Compliance on AWS](https://aws.amazon.com/compliance/gdpr-center/)
- [HIPAA Compliance on AWS](https://aws.amazon.com/compliance/hipaa-compliance/)
- [PCI DSS on AWS](https://aws.amazon.com/compliance/pci-dss-level-1-faqs/)

---

**Document Owner:** Security Team  
**Approved By:** CISO  
**Review Cycle:** Quarterly  
**Next Review:** April 2026
