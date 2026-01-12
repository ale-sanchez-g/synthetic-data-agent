# Synthetic Data Generator Agent - Architecture Documentation

**Version:** 1.0  
**Last Updated:** January 12, 2026  
**Status:** Design Phase

## Executive Summary

The Synthetic Data Generator Agent is an AI-powered system leveraging AWS Bedrock Agent with Claude 3 Sonnet to generate high-quality, compliant synthetic datasets. The architecture follows AWS Well-Architected Framework principles with emphasis on security, scalability, and cost optimization.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Component Design](#component-design)
3. [Data Flow](#data-flow)
4. [Integration Patterns](#integration-patterns)
5. [Bounded Contexts (DDD)](#bounded-contexts-ddd)
6. [Architecture Decisions](#architecture-decisions)

---

## Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Client Layer                                │
│  (API Gateway / Application / CLI)                                   │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    AWS Bedrock Agent                                 │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Foundation Model: Claude 3 Sonnet                           │   │
│  │  - Natural language processing                               │   │
│  │  - Intent recognition                                        │   │
│  │  - Response generation                                       │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                             │                                        │
│  ┌─────────────────────────┼─────────────────────────┐             │
│  │                         │                         │             │
│  ▼                         ▼                         ▼             │
│ ┌────────────┐    ┌──────────────┐    ┌──────────────────┐       │
│ │ Knowledge  │    │Action Groups │    │  Agent Prompt    │       │
│ │    Base    │    │              │    │  Instructions    │       │
│ └────────────┘    └──────────────┘    └──────────────────┘       │
└─────────────────────────────────────────────────────────────────────┘
         │                     │
         │                     ▼
         │         ┌────────────────────────────┐
         │         │  Lambda Action Functions   │
         │         ├────────────────────────────┤
         │         │ • generate_synthetic_data  │
         │         │ • validate_schema          │
         │         │ • calculate_quality_metrics│
         │         └────────┬───────────────────┘
         │                  │
         ▼                  ▼
┌──────────────────┐  ┌─────────────────────────┐
│  OpenSearch      │  │   Storage Layer         │
│  Serverless      │  ├─────────────────────────┤
│                  │  │ • S3 (Generated Data)   │
│ • Vector Store   │  │ • S3 (Knowledge Base)   │
│ • Schema Index   │  │ • DynamoDB (History)    │
│ • Embeddings     │  └─────────────────────────┘
└──────────────────┘
         │
         ▼
┌──────────────────────────────────────────┐
│        Monitoring & Security             │
├──────────────────────────────────────────┤
│ • CloudWatch Logs & Metrics              │
│ • KMS Encryption                         │
│ • IAM Roles & Policies                   │
│ • AWS WAF (Optional)                     │
└──────────────────────────────────────────┘
```

---

## Component Design

### 1. Bedrock Agent Layer

**Purpose:** Orchestrates the synthetic data generation workflow using natural language understanding.

**Components:**
- **Foundation Model:** anthropic.claude-3-sonnet-20240229-v1:0
- **Agent Instructions:** Defines behavior, tone, and response patterns
- **Action Groups:** Maps intents to Lambda functions
- **Knowledge Base Integration:** RAG for schema templates and patterns

**Responsibilities:**
- Parse user requests and extract parameters
- Coordinate action group invocations
- Retrieve relevant context from knowledge base
- Generate natural language responses

**AWS Services:**
- AWS Bedrock Agent
- Amazon Bedrock Runtime

---

### 2. Knowledge Base Layer

**Purpose:** Provides semantic search and retrieval of schema templates, data patterns, and best practices.

**Components:**

#### OpenSearch Serverless Collection
- **Type:** Vector search enabled
- **Index Strategy:** Schema templates indexed by domain and complexity
- **Embedding Model:** amazon.titan-embed-text-v1
- **Data Source:** S3 bucket with schema templates

#### S3 Knowledge Base Bucket
- **Structure:**
  ```
  knowledge-base/
  ├── schemas/
  │   ├── healthcare/
  │   ├── finance/
  │   ├── retail/
  │   └── general/
  ├── patterns/
  │   ├── relationships/
  │   └── constraints/
  └── compliance/
      ├── gdpr/
      ├── hipaa/
      └── pci-dss/
  ```

**Responsibilities:**
- Store and index domain-specific schemas
- Provide semantic search capabilities
- Maintain compliance templates
- Version schema patterns

---

### 3. Action Function Layer

**Purpose:** Execute specialized data generation, validation, and quality assessment tasks.

#### 3.1 Generate Synthetic Data Function

**Configuration:**
- Runtime: Python 3.11
- Memory: 1024 MB
- Timeout: 300 seconds
- Concurrency: 10 (adjustable)

**Input Schema:**
```json
{
  "schema": {},
  "record_count": 1000,
  "output_format": "json|csv|parquet",
  "compliance_rules": [],
  "quality_constraints": {}
}
```

**Responsibilities:**
- Parse and validate input schema
- Generate synthetic records using Faker and custom generators
- Apply compliance rules and constraints
- Store output to S3
- Record generation metadata to DynamoDB

**Dependencies:**
- Faker library (Lambda Layer)
- boto3 for AWS service interaction
- jsonschema for validation

#### 3.2 Validate Schema Function

**Configuration:**
- Runtime: Python 3.11
- Memory: 512 MB
- Timeout: 60 seconds

**Responsibilities:**
- Validate JSON Schema compliance
- Check for required fields and types
- Validate constraints and patterns
- Return detailed validation results

#### 3.3 Calculate Quality Metrics Function

**Configuration:**
- Runtime: Python 3.11
- Memory: 512 MB
- Timeout: 120 seconds

**Responsibilities:**
- Calculate statistical distributions
- Assess uniqueness and cardinality
- Validate referential integrity
- Measure compliance adherence
- Generate quality report

---

### 4. Storage Layer

#### 4.1 S3 Bucket - Generated Data

**Purpose:** Store generated synthetic datasets

**Configuration:**
- **Versioning:** Enabled
- **Encryption:** SSE-KMS
- **Lifecycle Policy:**
  - Transition to IA after 90 days
  - Transition to Glacier after 180 days
  - Expire after 365 days (configurable)
- **Object Structure:**
  ```
  generated-data/
  ├── {environment}/
  │   ├── {year}/
  │   │   ├── {month}/
  │   │   │   ├── {day}/
  │   │   │   │   ├── {generation_id}/
  │   │   │   │   │   ├── data.json
  │   │   │   │   │   ├── metadata.json
  │   │   │   │   │   └── quality_report.json
  ```

#### 4.2 DynamoDB Table - Generation History

**Purpose:** Track generation requests and metadata

**Schema:**
- **Partition Key:** generation_id (String)
- **Sort Key:** timestamp (Number)
- **GSI 1:** status-timestamp-index
  - PK: status
  - SK: timestamp
- **GSI 2:** user-timestamp-index
  - PK: user_id
  - SK: timestamp

**Attributes:**
```json
{
  "generation_id": "uuid",
  "timestamp": 1234567890,
  "user_id": "string",
  "status": "pending|processing|completed|failed",
  "schema_digest": "sha256",
  "record_count": 1000,
  "output_format": "json",
  "s3_location": "s3://bucket/path",
  "quality_metrics": {},
  "error_message": "string",
  "ttl": 1234567890
}
```

**Configuration:**
- **Billing Mode:** Pay-per-request (on-demand)
- **Point-in-time Recovery:** Enabled
- **TTL:** Enabled (configurable retention)
- **Encryption:** AWS managed CMK

---

### 5. Security Layer

**Components:**

#### IAM Roles and Policies
- Bedrock Agent execution role
- Lambda execution roles (per function)
- Knowledge Base service role
- OpenSearch access roles

#### Encryption
- **At Rest:** KMS encryption for S3, DynamoDB, CloudWatch
- **In Transit:** TLS 1.2+ for all communications
- **Key Management:** Customer managed keys with automatic rotation

#### Network Security (Optional VPC)
- Private subnets for Lambda functions
- VPC endpoints for AWS services
- Security groups with least privilege
- NAT Gateway for outbound internet

---

### 6. Monitoring & Observability Layer

**CloudWatch Logs:**
- Bedrock Agent invocations
- Lambda function executions
- OpenSearch operations
- API Gateway requests

**CloudWatch Metrics:**
- Custom metrics for generation statistics
- Lambda performance metrics
- DynamoDB capacity metrics
- S3 storage metrics

**CloudWatch Alarms:**
- Lambda error rate > 5%
- Lambda duration > p99 threshold
- DynamoDB throttling events
- S3 storage exceeds threshold

**CloudWatch Dashboard:**
- Real-time generation statistics
- System health indicators
- Cost tracking widgets
- Performance trends

---

## Data Flow

### Primary Flow: Generate Synthetic Data

```
1. User Request
   ↓
2. Bedrock Agent (Intent Recognition)
   ↓
3. Knowledge Base Query (Optional - retrieve schema template)
   ↓
4. Action Group Invocation
   ↓
5. Lambda: Generate Synthetic Data
   ├─→ Parse schema
   ├─→ Generate records
   ├─→ Apply compliance rules
   ├─→ Write to S3
   └─→ Record to DynamoDB
   ↓
6. Lambda: Calculate Quality Metrics (Optional)
   ├─→ Read generated data from S3
   ├─→ Calculate statistics
   └─→ Write quality report to S3
   ↓
7. Bedrock Agent (Format Response)
   ↓
8. Return to User
```

### Secondary Flow: Schema Validation

```
1. User provides schema
   ↓
2. Bedrock Agent
   ↓
3. Action Group: Validate Schema
   ↓
4. Lambda: Validate Schema
   ├─→ Parse JSON Schema
   ├─→ Validate structure
   └─→ Return validation results
   ↓
5. Bedrock Agent (Natural language response)
   ↓
6. Return to User
```

---

## Integration Patterns

### 1. Request-Response Pattern
- Synchronous invocations for small datasets (< 10k records)
- Immediate response to user
- Suitable for interactive use cases

### 2. Asynchronous Pattern
- For large dataset generation (> 10k records)
- Lambda invoked asynchronously
- User receives generation_id for tracking
- Polling or notification on completion

### 3. Event-Driven Pattern
- S3 event notifications trigger downstream processing
- DynamoDB streams for audit logging
- CloudWatch Events for scheduled tasks

---

## Bounded Contexts (DDD)

### 1. Data Generation Context

**Ubiquitous Language:**
- Schema
- Synthetic Record
- Generation Request
- Data Generator
- Compliance Rule

**Entities:**
- GenerationRequest
- SyntheticDataset
- SchemaDefinition

**Value Objects:**
- RecordCount
- OutputFormat
- QualityConstraints

**Aggregates:**
- GenerationRequest (root) with associated SyntheticDataset

**Domain Events:**
- GenerationRequested
- GenerationCompleted
- GenerationFailed

---

### 2. Schema Management Context

**Ubiquitous Language:**
- Schema Template
- Field Definition
- Constraint
- Validator

**Entities:**
- SchemaTemplate
- FieldDefinition

**Value Objects:**
- DataType
- ValidationRule
- FieldConstraint

**Aggregates:**
- SchemaTemplate (root) with FieldDefinitions

---

### 3. Quality Assurance Context

**Ubiquitous Language:**
- Quality Metric
- Statistical Distribution
- Uniqueness Score
- Compliance Score

**Value Objects:**
- QualityMetric
- DistributionStatistics
- ComplianceResult

**Domain Services:**
- QualityMetricsCalculator
- ComplianceValidator

---

## Architecture Decisions

### ADR-001: Use AWS Bedrock Agent for Orchestration

**Status:** Accepted

**Context:**
Need an intelligent orchestration layer that can understand natural language requests and coordinate multiple actions.

**Decision:**
Use AWS Bedrock Agent with Claude 3 Sonnet as the primary orchestration mechanism.

**Consequences:**
- Pros: Natural language interface, managed service, built-in conversational memory
- Cons: AWS-specific, limited customization of agent behavior
- Tradeoffs: Vendor lock-in vs. reduced operational overhead

---

### ADR-002: Use Lambda Functions for Action Groups

**Status:** Accepted

**Context:**
Need serverless compute for executing data generation and validation tasks.

**Decision:**
Implement action groups as AWS Lambda functions with Python 3.11 runtime.

**Consequences:**
- Pros: Serverless, auto-scaling, pay-per-use, easy integration with Bedrock
- Cons: Cold starts, execution time limits (15 min max)
- Tradeoffs: Implemented async pattern for large dataset generation

---

### ADR-003: OpenSearch Serverless for Knowledge Base

**Status:** Accepted

**Context:**
Need vector search capabilities for semantic retrieval of schema templates.

**Decision:**
Use OpenSearch Serverless with Titan embeddings for knowledge base.

**Consequences:**
- Pros: Managed service, vector search native, automatic scaling
- Cons: Higher cost than self-managed, limited configuration options
- Tradeoffs: Cost vs. operational simplicity accepted

---

### ADR-004: DynamoDB for Generation History

**Status:** Accepted

**Context:**
Need to track generation requests with fast queries by multiple access patterns.

**Decision:**
Use DynamoDB with on-demand billing and multiple GSIs.

**Consequences:**
- Pros: Serverless, single-digit millisecond latency, auto-scaling
- Cons: Limited query flexibility, GSI costs
- Tradeoffs: Query flexibility vs. performance and scalability

---

### ADR-005: S3 for Data Storage

**Status:** Accepted

**Context:**
Need durable, scalable storage for generated datasets.

**Decision:**
Use S3 with lifecycle policies and versioning enabled.

**Consequences:**
- Pros: Unlimited scalability, 11 nines durability, lifecycle management
- Cons: Eventual consistency for some operations
- Tradeoffs: Consistency model accepted for this use case

---

### ADR-006: KMS for Encryption

**Status:** Accepted

**Context:**
Need encryption at rest for all data, especially for compliance requirements.

**Decision:**
Use AWS KMS with customer managed keys for all encryption.

**Consequences:**
- Pros: Centralized key management, audit trail, automatic rotation
- Cons: Additional cost per key and API call, key management overhead
- Tradeoffs: Security and compliance requirements justify additional cost

---

## Scalability Considerations

### Horizontal Scaling
- Lambda concurrency limits (default 1000, can request increase)
- DynamoDB auto-scaling for capacity
- OpenSearch Serverless automatic scaling

### Vertical Scaling
- Lambda memory configuration (512MB - 10GB)
- Optimize function code and dependencies
- Use Lambda layers for shared libraries

### Performance Optimization
- Connection pooling for DynamoDB and S3
- Batch operations where possible
- Caching frequently accessed schemas
- Async processing for large datasets

---

## Disaster Recovery

### Backup Strategy
- **S3:** Cross-region replication (optional)
- **DynamoDB:** Point-in-time recovery enabled, on-demand backups
- **Infrastructure:** Terraform state in S3 with versioning

### Recovery Objectives
- **RTO (Recovery Time Objective):** < 4 hours
- **RPO (Recovery Point Objective):** < 1 hour

### Multi-Region Strategy (Future)
- Active-passive deployment across regions
- Route53 health checks and failover
- Cross-region S3 replication
- DynamoDB global tables

---

## Cost Optimization

### Right-Sizing
- Lambda memory optimized per function
- DynamoDB on-demand billing for variable load
- S3 lifecycle policies for cost-effective storage tiers

### Reserved Capacity (Future)
- Consider reserved capacity for predictable workloads
- Savings Plans for compute resources

### Cost Monitoring
- AWS Cost Explorer tags by environment and component
- Budget alerts for cost anomalies
- CloudWatch metrics for resource utilization

---

## Security Best Practices

1. **Principle of Least Privilege:** IAM roles with minimal required permissions
2. **Defense in Depth:** Multiple layers of security controls
3. **Encryption Everywhere:** At rest and in transit
4. **Audit Logging:** CloudTrail enabled for all API calls
5. **Network Isolation:** VPC for sensitive workloads (optional)
6. **Secret Management:** AWS Secrets Manager for sensitive configuration
7. **Compliance:** GDPR, HIPAA, PCI-DSS considerations built-in

---

## Future Enhancements

1. **API Gateway Integration:** REST API for programmatic access
2. **Step Functions:** Complex workflow orchestration
3. **EventBridge:** Event-driven integrations
4. **SageMaker:** ML-based synthetic data generation
5. **QuickSight:** Visualization of quality metrics
6. **Glue Catalog:** Data catalog integration
7. **Multi-Region:** Active-active deployment

---

## Appendix

### Technology Stack Summary

| Component | Technology | Version |
|-----------|-----------|---------|
| Foundation Model | Claude 3 Sonnet | 20240229-v1:0 |
| Runtime | Python | 3.11 |
| IaC | Terraform | ~> 1.6 |
| Compute | AWS Lambda | N/A |
| Storage | S3, DynamoDB | N/A |
| Vector Store | OpenSearch Serverless | N/A |
| Orchestration | Bedrock Agent | N/A |
| Monitoring | CloudWatch | N/A |

### Glossary

- **Synthetic Data:** Artificially generated data that mimics real data
- **RAG:** Retrieval Augmented Generation
- **Action Group:** Bedrock Agent feature mapping intents to Lambda functions
- **Knowledge Base:** Vector store with semantic search capabilities
- **Foundation Model:** Large language model powering the agent

---

**Document Owner:** Infrastructure Team  
**Review Cycle:** Quarterly  
**Next Review:** April 2026
