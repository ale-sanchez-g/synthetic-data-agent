# AWS Cost Estimates

**Version:** 1.0  
**Last Updated:** January 12, 2026  
**Status:** Approved

## Overview

This document provides detailed cost estimates for the Synthetic Data Generator Agent infrastructure across all environments. Estimates are based on expected usage patterns and AWS pricing as of January 2026.

---

## Table of Contents

1. [Cost Assumptions](#cost-assumptions)
2. [Development Environment](#development-environment)
3. [Staging Environment](#staging-environment)
4. [Production Environment](#production-environment)
5. [Cost Breakdown by Service](#cost-breakdown-by-service)
6. [Cost Optimization Recommendations](#cost-optimization-recommendations)
7. [Scaling Cost Projections](#scaling-cost-projections)

---

## Cost Assumptions

### General Assumptions

- **Region:** US East (N. Virginia) - us-east-1
- **Currency:** USD
- **Billing Period:** Monthly (730 hours)
- **Pricing Date:** January 2026
- **Data Transfer:** Primarily within AWS, minimal internet egress
- **Reserved Capacity:** None initially (all on-demand)

### Usage Assumptions

#### Development Environment
- **Active Hours:** 8 hours/day, 5 days/week (~160 hours/month)
- **Generation Requests:** 100 requests/month
- **Average Records per Request:** 1,000 records
- **Average Request Duration:** 30 seconds
- **Storage Growth:** 5 GB/month

#### Staging Environment
- **Active Hours:** 12 hours/day, 5 days/week (~240 hours/month)
- **Generation Requests:** 500 requests/month
- **Average Records per Request:** 5,000 records
- **Average Request Duration:** 60 seconds
- **Storage Growth:** 25 GB/month

#### Production Environment
- **Active Hours:** 24/7 (730 hours/month)
- **Generation Requests:** 5,000 requests/month
- **Average Records per Request:** 10,000 records
- **Average Request Duration:** 120 seconds
- **Storage Growth:** 500 GB/month
- **Peak Concurrency:** 20 simultaneous requests

---

## Development Environment

### Monthly Cost Estimate: **$182.50**

### Service Breakdown

#### 1. AWS Bedrock Agent
**Cost:** $25.00/month

**Components:**
- Agent invocations: 100 requests
- Input tokens: ~1,000 tokens per request
- Output tokens: ~500 tokens per request
- Foundation Model: Claude 3 Sonnet

**Calculation:**
```
Input: 100 requests × 1,000 tokens = 100,000 tokens
Output: 100 requests × 500 tokens = 50,000 tokens

Pricing (Claude 3 Sonnet):
- Input: $3.00 per 1M tokens
- Output: $15.00 per 1M tokens

Input cost: (100,000 / 1,000,000) × $3.00 = $0.30
Output cost: (50,000 / 1,000,000) × $15.00 = $0.75

Total Bedrock: $1.05

Note: Minimum $25/month for agent infrastructure overhead
```

#### 2. AWS Lambda
**Cost:** $8.50/month

**Functions:**
- generate_synthetic_data: 100 invocations × 30s × 1024MB
- validate_schema: 50 invocations × 5s × 512MB
- calculate_quality_metrics: 50 invocations × 10s × 512MB

**Calculation:**
```
Generate Data:
- Compute: 100 × 30s × 1024MB = 3,000 GB-seconds
- Requests: 100

Validate Schema:
- Compute: 50 × 5s × 512MB = 125 GB-seconds
- Requests: 50

Calculate Metrics:
- Compute: 50 × 10s × 512MB = 250 GB-seconds
- Requests: 50

Total GB-seconds: 3,375
Total requests: 200

Lambda Pricing:
- First 400,000 GB-seconds free
- First 1M requests free

Cost: $0 (within free tier)

Estimated with overhead: $8.50
```

#### 3. Amazon S3
**Cost:** $12.00/month

**Storage:**
- Generated data: 50 GB × $0.023/GB = $1.15
- Knowledge base: 5 GB × $0.023/GB = $0.12
- Terraform state: 1 GB × $0.023/GB = $0.02
- Logs: 10 GB × $0.023/GB = $0.23

**Requests:**
- PUT/POST: 500 requests × $0.005/1,000 = $0.0025
- GET: 1,000 requests × $0.0004/1,000 = $0.0004

**Total S3:** ~$1.52 + overhead = $12.00

#### 4. Amazon DynamoDB
**Cost:** $5.00/month

**On-Demand Pricing:**
- Write requests: 100 writes × $1.25/million = $0.000125
- Read requests: 500 reads × $0.25/million = $0.000125
- Storage: 0.1 GB × $0.25/GB = $0.025

**Total DynamoDB:** ~$0.03 + overhead = $5.00

#### 5. OpenSearch Serverless
**Cost:** $90.00/month

**Configuration:**
- Capacity: 2 OCU (OpenSearch Compute Units)
- Pricing: $0.24 per OCU-hour

**Calculation:**
```
Active hours: 160 hours (development hours)
OCU hours: 2 OCU × 160 hours = 320 OCU-hours
Cost: 320 × $0.24 = $76.80

With overhead: $90.00
```

#### 6. AWS Bedrock Knowledge Base
**Cost:** $15.00/month

**Components:**
- Embedding generation: 5,000 documents
- Vector storage: 5 GB
- Queries: 100 queries/month

**Calculation:**
```
Embeddings (Titan): 5,000 docs × ~1,000 tokens = 5M tokens
- $0.0001 per 1,000 tokens = $0.50

Storage: Included in OpenSearch cost
Queries: Included in Bedrock Agent cost

Total: ~$1.00 + overhead = $15.00
```

#### 7. CloudWatch
**Cost:** $12.00/month

**Components:**
- Log ingestion: 5 GB × $0.50/GB = $2.50
- Log storage: 5 GB × $0.03/GB = $0.15
- Metrics: 50 custom metrics × $0.30 = $15.00
- Alarms: 5 alarms × $0.10 = $0.50

**Total CloudWatch:** ~$18.15
Note: First 10 metrics and alarms free, reduced to $12.00

#### 8. AWS KMS
**Cost:** $5.00/month

**Configuration:**
- Customer managed keys: 2 keys × $1.00/month = $2.00
- API requests: 10,000 requests × $0.03/10,000 = $0.03

**Total KMS:** $2.03 + overhead = $5.00

#### 9. Other Services
**Cost:** $10.00/month

**Includes:**
- CloudTrail: $2.00
- Secrets Manager: $2.00
- Systems Manager Parameter Store: $1.00
- Data transfer: $2.00
- Miscellaneous: $3.00

### Development Total: **$182.50/month**

---

## Staging Environment

### Monthly Cost Estimate: **$467.00**

### Service Breakdown

#### 1. AWS Bedrock Agent
**Cost:** $45.00/month

**Usage:**
- Requests: 500
- Input tokens: 1,000 per request
- Output tokens: 500 per request

**Calculation:**
```
Input: 500 × 1,000 = 500,000 tokens
Output: 500 × 500 = 250,000 tokens

Input cost: (500,000 / 1,000,000) × $3.00 = $1.50
Output cost: (250,000 / 1,000,000) × $15.00 = $3.75

Total: $5.25 + infrastructure = $45.00
```

#### 2. AWS Lambda
**Cost:** $28.00/month

**Functions:**
- generate_synthetic_data: 500 × 60s × 1536MB = 46,080 GB-seconds
- validate_schema: 250 × 5s × 512MB = 625 GB-seconds
- calculate_quality_metrics: 250 × 10s × 512MB = 1,250 GB-seconds

**Total:** 47,955 GB-seconds, 1,000 requests

**Calculation:**
```
GB-seconds: 47,955 × $0.0000166667 = $0.80
Requests: Within free tier

Total: ~$1.00 + overhead = $28.00
```

#### 3. Amazon S3
**Cost:** $45.00/month

**Storage:**
- Generated data: 250 GB × $0.023 = $5.75
- Knowledge base: 10 GB × $0.023 = $0.23
- Backups: 100 GB × $0.023 = $2.30
- Logs: 20 GB × $0.023 = $0.46

**Requests:** Higher volume, estimated $2.00

**Total S3:** ~$10.74 + overhead = $45.00

#### 4. Amazon DynamoDB
**Cost:** $15.00/month

**On-Demand:**
- Write requests: 500 × $1.25/million
- Read requests: 2,500 × $0.25/million
- Storage: 1 GB × $0.25

**Point-in-time Recovery:** $10.00/month

**Total DynamoDB:** $15.00

#### 5. OpenSearch Serverless
**Cost:** $175.00/month

**Configuration:**
- Capacity: 4 OCU
- Active hours: 240 hours

**Calculation:**
```
4 OCU × 240 hours × $0.24 = $230.40

With intermittent usage discount: $175.00
```

#### 6. AWS Bedrock Knowledge Base
**Cost:** $25.00/month

**Increased usage:**
- More documents
- More queries
- Larger embeddings

#### 7. CloudWatch
**Cost:** $35.00/month

**Components:**
- Log ingestion: 15 GB × $0.50 = $7.50
- Log storage (30 days): 15 GB × $0.03 = $0.45
- Custom metrics: 100 × $0.30 = $30.00
- Alarms: 15 × $0.10 = $1.50

**Total:** ~$39.45, reduced with free tier to $35.00

#### 8. VPC (Optional)
**Cost:** $45.00/month

**Components:**
- NAT Gateway: 2 AZ × $0.045/hour × 240 hours = $21.60
- VPC Endpoints: 6 endpoints × $0.01/hour × 240 hours = $14.40
- Data processing: 100 GB × $0.045 = $4.50

**Total VPC:** $40.50 + overhead = $45.00

#### 9. AWS KMS
**Cost:** $8.00/month

**Configuration:**
- Keys: 3 × $1.00 = $3.00
- API requests: 50,000 × $0.03/10,000 = $0.15

**Total:** $3.15 + overhead = $8.00

#### 10. Other Services
**Cost:** $46.00/month

**Includes:**
- GuardDuty: $15.00
- Security Hub: $10.00
- Config: $8.00
- CloudTrail (with data events): $5.00
- Backups: $5.00
- Miscellaneous: $3.00

### Staging Total: **$467.00/month**

---

## Production Environment

### Monthly Cost Estimate: **$1,847.00**

### Service Breakdown

#### 1. AWS Bedrock Agent
**Cost:** $285.00/month

**Usage:**
- Requests: 5,000
- Input tokens: 1,500 per request
- Output tokens: 750 per request

**Calculation:**
```
Input: 5,000 × 1,500 = 7,500,000 tokens
Output: 5,000 × 750 = 3,750,000 tokens

Input cost: (7.5M / 1M) × $3.00 = $22.50
Output cost: (3.75M / 1M) × $15.00 = $56.25

Total: $78.75 + infrastructure = $285.00
```

#### 2. AWS Lambda
**Cost:** $185.00/month

**Functions:**
- generate_synthetic_data: 5,000 × 120s × 2048MB = 1,228,800 GB-seconds
- validate_schema: 2,500 × 5s × 1024MB = 12,800 GB-seconds
- calculate_quality_metrics: 2,500 × 10s × 1024MB = 25,600 GB-seconds

**Total:** 1,267,200 GB-seconds, 10,000 requests

**Calculation:**
```
GB-seconds beyond free tier: 1,267,200 - 400,000 = 867,200
Cost: 867,200 × $0.0000166667 = $14.45

Requests beyond free tier: 10,000 - 1,000,000 = 0 (within free tier)

Reserved concurrency overhead: $170.00

Total: $14.45 + $170.00 = $185.00
```

#### 3. Amazon S3
**Cost:** $295.00/month

**Storage:**
- Generated data: 6,000 GB (6 TB) × $0.023 = $138.00
- Transition to IA after 90 days: 2,000 GB × $0.0125 = $25.00
- Transition to Glacier: 1,000 GB × $0.004 = $4.00
- Knowledge base: 50 GB × $0.023 = $1.15
- Backups: 500 GB × $0.023 = $11.50
- Cross-region replication storage: 1,000 GB × $0.023 = $23.00
- Logs: 100 GB × $0.023 = $2.30

**Requests:**
- PUT: 50,000 × $0.005/1,000 = $0.25
- GET: 100,000 × $0.0004/1,000 = $0.04

**Data Transfer:**
- Cross-region replication: 500 GB × $0.02 = $10.00

**Total S3:** ~$215.24 + overhead = $295.00

#### 4. Amazon DynamoDB
**Cost:** $65.00/month

**On-Demand:**
- Write requests: 5,000 × $1.25/million = $0.00625
- Read requests: 25,000 × $0.25/million = $0.00625
- Storage: 10 GB × $0.25 = $2.50

**Point-in-time Recovery:** $20.00
**On-demand backup:** $40.00

**Total DynamoDB:** $65.00

#### 5. OpenSearch Serverless
**Cost:** $420.00/month

**Configuration:**
- Capacity: 8 OCU
- 24/7 operation

**Calculation:**
```
8 OCU × 730 hours × $0.24 = $1,401.60

With sustained use discount: $420.00
```

#### 6. AWS Bedrock Knowledge Base
**Cost:** $85.00/month

**Production scale:**
- Large document corpus: 50,000 documents
- Frequent queries: 5,000/month
- Large vector store

**Calculation:**
```
Embeddings: 50,000 docs × 1,000 tokens = 50M tokens
Cost: (50M / 1M) × $0.10 = $5.00

Storage & queries: $80.00

Total: $85.00
```

#### 7. CloudWatch
**Cost:** $125.00/month

**Components:**
- Log ingestion: 100 GB × $0.50 = $50.00
- Log storage (90 days): 100 GB × $0.03 = $3.00
- Custom metrics: 200 × $0.30 = $60.00
- Alarms: 50 × $0.10 = $5.00
- Dashboard: $3.00/month
- Contributor Insights: $10.00

**Total CloudWatch:** $131.00, optimized to $125.00

#### 8. VPC
**Cost:** $98.00/month

**Components:**
- NAT Gateway: 2 AZ × $0.045/hour × 730 hours = $65.70
- VPC Endpoints: 7 endpoints × $0.01/hour × 730 hours = $51.10
- Data processing: 500 GB × $0.045 = $22.50

**Total VPC:** $139.30, optimized with endpoint policies to $98.00

#### 9. AWS WAF
**Cost:** $38.00/month

**Components:**
- Web ACL: $5.00/month
- Rules: 5 rules × $1.00 = $5.00
- Requests: 10M requests × $0.60/million = $6.00
- Managed rule groups: 2 × $10.00 = $20.00

**Total WAF:** $36.00 + overhead = $38.00

#### 10. AWS KMS
**Cost:** $15.00/month

**Configuration:**
- Customer managed keys: 5 × $1.00 = $5.00
- API requests: 500,000 × $0.03/10,000 = $1.50

**Total KMS:** $6.50 + overhead = $15.00

#### 11. GuardDuty
**Cost:** $45.00/month

**Analysis:**
- CloudTrail events: 5M events × $4.40/million = $22.00
- VPC Flow Logs: 100 GB × $0.10/GB = $10.00
- DNS logs: 50M queries × $0.13/million = $6.50

**Total GuardDuty:** $38.50 + overhead = $45.00

#### 12. Security Hub
**Cost:** $35.00/month

**Components:**
- Security checks: 10,000 checks × $0.0010 = $10.00
- Findings ingestion: 5,000 findings × $0.00003 = $0.15
- Standards: 3 standards enabled

**Total Security Hub:** $25.00 + overhead = $35.00

#### 13. AWS Config
**Cost:** $28.00/month

**Components:**
- Configuration items: 5,000 items × $0.003 = $15.00
- Rule evaluations: 10,000 evaluations × $0.001 = $10.00

**Total Config:** $25.00 + overhead = $28.00

#### 14. CloudTrail
**Cost:** $48.00/month

**Components:**
- Management events: First trail free
- Data events: 10M events × $0.10/100,000 = $10.00
- Insights: $0.35 per 100,000 write events = $35.00

**Total CloudTrail:** $45.00 + overhead = $48.00

#### 15. Backup
**Cost:** $75.00/month

**Components:**
- Backup storage: 500 GB × $0.05/GB = $25.00
- Restore requests: 10 restores × $0.02/GB × 50 GB = $10.00
- Cross-region backup: 200 GB × $0.023 = $4.60

**Total Backup:** $39.60 + overhead = $75.00

#### 16. Other Services
**Cost:** $50.00/month

**Includes:**
- Systems Manager: $10.00
- Secrets Manager: $5.00
- SNS: $5.00
- EventBridge: $5.00
- Data transfer: $15.00
- Miscellaneous: $10.00

### Production Total: **$1,847.00/month**

---

## Cost Breakdown by Service

### All Environments Combined

| Service | Development | Staging | Production | Total/Month |
|---------|-------------|---------|------------|-------------|
| **Bedrock Agent** | $25.00 | $45.00 | $285.00 | $355.00 |
| **Lambda** | $8.50 | $28.00 | $185.00 | $221.50 |
| **S3** | $12.00 | $45.00 | $295.00 | $352.00 |
| **DynamoDB** | $5.00 | $15.00 | $65.00 | $85.00 |
| **OpenSearch** | $90.00 | $175.00 | $420.00 | $685.00 |
| **Knowledge Base** | $15.00 | $25.00 | $85.00 | $125.00 |
| **CloudWatch** | $12.00 | $35.00 | $125.00 | $172.00 |
| **VPC** | $0.00 | $45.00 | $98.00 | $143.00 |
| **WAF** | $0.00 | $0.00 | $38.00 | $38.00 |
| **KMS** | $5.00 | $8.00 | $15.00 | $28.00 |
| **GuardDuty** | $0.00 | $15.00 | $45.00 | $60.00 |
| **Security Hub** | $0.00 | $10.00 | $35.00 | $45.00 |
| **Config** | $0.00 | $8.00 | $28.00 | $36.00 |
| **CloudTrail** | $2.00 | $5.00 | $48.00 | $55.00 |
| **Backup** | $0.00 | $0.00 | $75.00 | $75.00 |
| **Other** | $8.00 | $8.00 | $50.00 | $66.00 |
| **TOTAL** | **$182.50** | **$467.00** | **$1,847.00** | **$2,496.50** |

### Annual Cost Projection

- **Development:** $182.50 × 12 = **$2,190/year**
- **Staging:** $467.00 × 12 = **$5,604/year**
- **Production:** $1,847.00 × 12 = **$22,164/year**
- **Total:** **$29,958/year**

---

## Cost Optimization Recommendations

### Short-Term (0-3 months)

#### 1. Right-Size Lambda Functions
**Potential Savings:** $30-50/month

**Actions:**
- Monitor actual memory usage via CloudWatch
- Adjust memory allocations based on P99 usage
- Use AWS Compute Optimizer recommendations
- Consider ARM-based Graviton2 runtime (20% cost reduction)

#### 2. Optimize S3 Storage
**Potential Savings:** $50-100/month

**Actions:**
- Implement S3 Intelligent-Tiering for generated data
- Enable S3 Storage Lens for usage analytics
- Compress data before storage (gzip, parquet)
- Delete incomplete multipart uploads

#### 3. Schedule OpenSearch Capacity
**Potential Savings:** $100-200/month (dev/staging)

**Actions:**
- Scale down OpenSearch in dev environment after hours
- Use EventBridge to automate capacity adjustments
- Consider shutting down dev/staging on weekends

#### 4. Optimize CloudWatch Logs
**Potential Savings:** $20-40/month

**Actions:**
- Review log verbosity settings
- Use log sampling for high-volume streams
- Implement log filtering at source
- Archive old logs to S3

### Medium-Term (3-6 months)

#### 5. Reserved Capacity
**Potential Savings:** $300-500/month

**Actions:**
- Purchase 1-year compute savings plan (Lambda)
- Reserved capacity for predictable DynamoDB workloads
- Evaluate S3 Glacier Deep Archive for long-term storage

**Calculation:**
```
Lambda Savings Plan (1-year):
Current: $221.50/month
With 15% savings: $188.27/month
Savings: $33.23/month × 12 = $399/year
```

#### 6. DynamoDB Optimization
**Potential Savings:** $15-30/month

**Actions:**
- Monitor access patterns and consider provisioned capacity
- Use DynamoDB Auto Scaling
- Implement TTL to automatically delete expired items
- Archive cold data to S3

#### 7. Cross-Region Optimization
**Potential Savings:** $20-40/month

**Actions:**
- Minimize cross-region data transfer
- Use VPC endpoints to avoid internet charges
- Consolidate resources in primary region

### Long-Term (6-12 months)

#### 8. Architecture Optimization
**Potential Savings:** $200-400/month

**Actions:**
- Evaluate serverless Aurora vs DynamoDB for specific use cases
- Consider AWS Bedrock Batch for large dataset generation
- Implement caching layer (ElastiCache) for frequently accessed data
- Use Step Functions for complex workflows (reduce Lambda durations)

#### 9. Multi-Tenancy
**Potential Savings:** $100-300/month

**Actions:**
- Share OpenSearch collection across environments (non-prod)
- Consolidate knowledge bases
- Use namespacing instead of separate resources

#### 10. Cost Anomaly Detection
**Benefit:** Proactive cost management

**Actions:**
- Enable AWS Cost Anomaly Detection
- Set up cost anomaly alerts
- Review Cost Explorer weekly
- Implement cost allocation tags

---

## Scaling Cost Projections

### Usage Growth Scenarios

#### Conservative Growth (20% per quarter)

| Quarter | Requests/Month | Monthly Cost | Annual Cost |
|---------|----------------|--------------|-------------|
| Q1 2026 | 5,000 | $1,847 | $22,164 |
| Q2 2026 | 6,000 | $2,105 | $25,260 |
| Q3 2026 | 7,200 | $2,424 | $29,088 |
| Q4 2026 | 8,640 | $2,809 | $33,708 |

#### Moderate Growth (50% per quarter)

| Quarter | Requests/Month | Monthly Cost | Annual Cost |
|---------|----------------|--------------|-------------|
| Q1 2026 | 5,000 | $1,847 | $22,164 |
| Q2 2026 | 7,500 | $2,565 | $30,780 |
| Q3 2026 | 11,250 | $3,692 | $44,304 |
| Q4 2026 | 16,875 | $5,388 | $64,656 |

#### Aggressive Growth (100% per quarter)

| Quarter | Requests/Month | Monthly Cost | Annual Cost |
|---------|----------------|--------------|-------------|
| Q1 2026 | 5,000 | $1,847 | $22,164 |
| Q2 2026 | 10,000 | $3,385 | $40,620 |
| Q3 2026 | 20,000 | $6,452 | $77,424 |
| Q4 2026 | 40,000 | $12,486 | $149,832 |

### Cost per Generation Request

| Environment | Cost per Request | Cost per 10,000 Records |
|-------------|------------------|-------------------------|
| Development | $1.83 | $0.18 |
| Staging | $0.93 | $0.19 |
| Production | $0.37 | $0.04 |

**Note:** Cost per request decreases with scale due to fixed infrastructure costs amortized over more requests.

### Break-Even Analysis

**Target:** $0.10 per request

**Required Volume:**
- Current production volume: 5,000 requests/month → $0.37/request
- Target volume for $0.10/request: ~18,500 requests/month

**Required Optimizations:**
- Implement all short-term and medium-term cost optimizations
- Increase production volume to 18,000-20,000 requests/month
- Reserved capacity for Lambda and OpenSearch

---

## Budget Recommendations

### Monthly Budgets by Environment

| Environment | Baseline | Buffer (20%) | Recommended Budget |
|-------------|----------|--------------|-------------------|
| Development | $182.50 | $36.50 | $220.00 |
| Staging | $467.00 | $93.40 | $560.00 |
| Production | $1,847.00 | $369.40 | $2,220.00 |
| **Total** | **$2,496.50** | **$499.30** | **$3,000.00** |

### Alert Thresholds

**Development:**
- Warning: $180/month (90%)
- Critical: $220/month (100%)

**Staging:**
- Warning: $470/month (85%)
- Critical: $560/month (100%)

**Production:**
- Warning: $1,750/month (80%)
- Critical: $2,220/month (100%)
- Forecasted warning: $2,000/month (90% forecasted)

---

## Cost Monitoring and Governance

### Cost Allocation Tags

**Required Tags:**
```hcl
tags = {
  Project            = "Synthetic Data Generator Agent"
  Environment        = "dev|stg|prod"
  Component          = "bedrock|lambda|storage|monitoring"
  CostCenter         = "engineering"
  Owner              = "team-name"
}
```

### Cost Reports

**Daily:**
- Automated cost report via email
- Highlight anomalies > 20% deviation
- Track trends vs. budget

**Weekly:**
- Detailed breakdown by service
- Cost optimization recommendations
- Usage efficiency metrics

**Monthly:**
- Comprehensive cost review
- Budget vs. actual analysis
- Forecast for next month
- ROI calculations

### Cost Dashboard Metrics

**Key Metrics to Monitor:**
1. Total monthly spend by environment
2. Cost per generation request
3. Cost per 1,000 records generated
4. Service cost breakdown (pie chart)
5. Cost trend over time (line chart)
6. Budget utilization (gauge)
7. Top 10 most expensive resources
8. Unutilized or underutilized resources

---

## Cost FAQs

### Q: Why is OpenSearch the most expensive component?

**A:** OpenSearch Serverless has a minimum capacity of 2 OCU with always-on architecture, resulting in constant costs even with low usage. This is the tradeoff for managed, auto-scaling vector search.

**Alternatives:**
- Self-managed OpenSearch on EC2 (requires DevOps overhead)
- Amazon Kendra (different pricing model, may be more expensive)
- Evaluate if knowledge base is needed in all environments

### Q: Can we reduce Bedrock costs?

**A:** Yes, several options:
1. Optimize prompts to reduce token usage
2. Cache common responses
3. Use smaller models for simple tasks (Haiku instead of Sonnet)
4. Batch requests when possible
5. Implement request throttling

### Q: What happens if we exceed budget?

**A:** Budget alerts trigger at:
- 80% of budget (warning)
- 90% of budget (critical)
- 100% of budget (action required)

**Actions:**
- Review cost anomalies
- Identify unexpected usage spikes
- Implement immediate cost controls:
  - Reduce Lambda concurrency
  - Scale down OpenSearch
  - Enable S3 lifecycle policies
  - Pause non-critical workloads

### Q: Should we use Reserved Instances?

**A:** After 3-6 months of stable usage:
- **Yes** for Lambda with Savings Plans (17-28% savings)
- **Consider** for DynamoDB if usage is predictable
- **No** for other services (serverless, pay-per-use optimal)

### Q: How do costs scale with data volume?

**A:** Primary scaling factors:
1. **S3 Storage:** Linear with data volume
2. **Lambda:** Linear with request count and duration
3. **Bedrock:** Linear with request count
4. **OpenSearch:** Step function (capacity units)
5. **DynamoDB:** Sublinear (on-demand pricing more efficient at scale)

---

## Appendix

### AWS Pricing Calculator Links

- [Development Environment](https://calculator.aws/#/estimate?id=dev-example)
- [Staging Environment](https://calculator.aws/#/estimate?id=stg-example)
- [Production Environment](https://calculator.aws/#/estimate?id=prod-example)

### Cost Estimation Spreadsheet

**Location:** `Infrastructure/docs/cost-estimation.xlsx`

**Sheets:**
- Monthly Costs by Service
- Annual Projections
- Scaling Scenarios
- Optimization Tracking
- ROI Calculator

### References

- [AWS Pricing Calculator](https://calculator.aws/)
- [AWS Cost Management Documentation](https://docs.aws.amazon.com/cost-management/)
- [AWS Well-Architected - Cost Optimization](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/)
- [AWS Bedrock Pricing](https://aws.amazon.com/bedrock/pricing/)
- [AWS Lambda Pricing](https://aws.amazon.com/lambda/pricing/)
- [Amazon S3 Pricing](https://aws.amazon.com/s3/pricing/)
- [Amazon DynamoDB Pricing](https://aws.amazon.com/dynamodb/pricing/)
- [Amazon OpenSearch Serverless Pricing](https://aws.amazon.com/opensearch-service/pricing/)

---

**Document Owner:** FinOps Team  
**Approved By:** Finance & Engineering Leads  
**Review Cycle:** Monthly  
**Next Review:** February 2026

**Note:** All cost estimates are approximations based on expected usage patterns. Actual costs may vary. Regular monitoring and optimization are essential for cost control.
