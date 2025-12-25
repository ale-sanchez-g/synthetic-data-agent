# Agent 1: Synthetic Data Generator Agent

## Step 1: Define Role and Goal

**Agent Role:** Synthetic Test Data Generation Specialist

**Primary Goal:** Generate realistic, diverse, and compliant synthetic test data for various testing scenarios including functional, performance, and security testing.

**Who It Helps:** QA Engineers, Test Automation Engineers, Performance Testers

**Output Type:** 
- Synthetic datasets in multiple formats (JSON, CSV, SQL, XML)
- Data generation reports with statistics
- Schema-compliant test data

---

## Step 2: Structured Input & Output Schema

### Input Schema (JSON)
```json
{
  "data_type": "string (user_profile|transaction|log_event|custom)",
  "volume": "integer (number of records)",
  "schema": {
    "fields": [
      {
        "name": "string",
        "type": "string (string|integer|date|email|phone|address)",
        "constraints": {
          "min": "number",
          "max": "number",
          "format": "string",
          "nullable": "boolean"
        }
      }
    ]
  },
  "compliance_requirements": ["GDPR", "HIPAA", "PCI-DSS"],
  "output_format": "string (json|csv|sql|parquet)",
  "destination": {
    "type": "string (s3|rds|local)",
    "location": "string"
  }
}
```

### Output Schema (JSON)
```json
{
  "generation_id": "uuid",
  "status": "string (success|partial|failed)",
  "records_generated": "integer",
  "output_location": "string",
  "data_quality_metrics": {
    "uniqueness_score": "float",
    "validity_score": "float",
    "distribution_analysis": "object"
  },
  "execution_time_ms": "integer",
  "errors": ["array of error messages"]
}
```

---

## Step 3: System Prompt for Behavior

### Core Agent Prompt
```
You are a Synthetic Data Generation Agent specialized in creating high-quality test data for quality engineering workflows.

Your responsibilities:
1. Analyze incoming data generation requests and validate schema definitions
2. Generate realistic synthetic data that maintains referential integrity
3. Ensure compliance with specified regulatory requirements (GDPR, HIPAA, etc.)
4. Provide data quality metrics and generation reports
5. Handle both structured and semi-structured data generation

Behavioral Guidelines:
- Always validate schemas before generation
- Prioritize data realism while maintaining privacy
- Generate diverse data distributions to cover edge cases
- Flag any compliance violations in the schema
- Provide clear error messages when generation fails
- Suggest schema improvements when detecting issues

Output Format:
- Generate data in requested format (JSON, CSV, SQL, Parquet)
- Include metadata about generation process
- Provide quality metrics for validation
```

---

## Step 4: Reasoning and Tool Use

### Available Tools:

1. **Faker Library Integration** - Generate realistic fake data
2. **AWS S3 Client** - Store generated datasets
3. **AWS RDS Client** - Insert data into test databases
4. **Schema Validator** - Validate input schemas
5. **Data Quality Analyzer** - Calculate quality metrics
6. **Compliance Checker** - Verify regulatory compliance

### Reasoning Framework: Chain-of-Thought

```
When generating synthetic data:
1. Parse and validate the incoming request schema
2. Identify data types and constraints
3. Determine generation strategy (random, pattern-based, template-based)
4. Check compliance requirements and adjust generation rules
5. Generate data in batches to manage memory
6. Validate generated data against schema
7. Calculate quality metrics
8. Write to specified destination
9. Return generation report
```

---

## Step 5: Multi-Agent Logic (Not Required)

This agent operates independently but can be orchestrated by the Master QE Agent.

---

## Step 6: Memory and Context (RAG)

### Memory Requirements:

**Short-term Memory:**
- Current generation request details
- In-progress generation statistics
- Validation errors encountered

**Long-term Memory (Vector Store):**
- Previously used schemas for similar data types
- Common data patterns by domain (e-commerce, healthcare, finance)
- Compliance rules and constraints
- Generation performance metrics history

**Tools:** 
- LangChain Memory for conversation context
- ChromaDB or FAISS for schema templates and patterns
- AWS DynamoDB for generation history

---

## Step 7: Voice/Vision Capabilities

Not required for this agent.

---

## Step 8: Output Formatting

**Output Formats:**
- JSON for API responses
- CSV for spreadsheet imports
- SQL INSERT statements for database loading
- Parquet for big data processing

**Markdown Report Example:**
```markdown
# Synthetic Data Generation Report

**Generation ID:** gen-12345-abcde
**Status:** ✅ Success
**Records Generated:** 10,000
**Execution Time:** 2.4 seconds

## Quality Metrics
- Uniqueness: 99.8%
- Validity: 100%
- Distribution: Normal

## Output Location
s3://test-data-bucket/synthetic/users_20231215.json
```

---

## Step 9: UI Integration

**FastAPI Endpoints:**
```python
POST /api/v1/synthetic-data/generate
GET /api/v1/synthetic-data/status/{generation_id}
GET /api/v1/synthetic-data/download/{generation_id}
POST /api/v1/synthetic-data/validate-schema
```

**Gradio Interface Components:**
- Schema builder (JSON editor)
- Volume selector
- Format dropdown
- Compliance checkboxes
- Generate button
- Download results panel

---

## Step 10: Evaluation and Monitoring

**Metrics to Track:**
- Generation success rate
- Average generation time per 1000 records
- Data quality scores (uniqueness, validity)
- Schema validation failure rate
- Compliance violation detection rate

**Logging:**
- CloudWatch Logs for all generation requests
- Custom metrics for performance tracking
- Error tracking with detailed stack traces

---

## AWS Bedrock Agent Configuration (Terraform)

### Prompt for VS Code AI Assistant:

```
Create a Terraform configuration for AWS Bedrock Agent that implements a Synthetic Data Generator Agent with the following requirements:

1. Agent Configuration:
   - Name: synthetic-data-generator-agent
   - Foundation Model: anthropic.claude-3-sonnet-20240229-v1:0
   - Role: Generate synthetic test data based on schema specifications

2. Action Groups:
   - Name: data-generation-actions
   - Lambda Functions:
     * generate_synthetic_data: Main data generation logic
     * validate_schema: Schema validation
     * calculate_quality_metrics: Data quality analysis
   - API Schema: OpenAPI 3.0 spec defining the input/output schemas shown above

3. Knowledge Base:
   - Name: data-generation-patterns-kb
   - Data Source: S3 bucket with schema templates and generation patterns
   - Vector Store: OpenSearch Serverless

4. Infrastructure:
   - Lambda Functions (Python 3.11 runtime)
   - S3 buckets for generated data storage
   - DynamoDB table for generation history
   - CloudWatch Log Groups
   - IAM roles and policies

5. Action Group Lambda Requirements:
   - Integrate with Faker library for data generation
   - Support multiple output formats (JSON, CSV, SQL, Parquet)
   - Implement compliance checks (GDPR, HIPAA)
   - Store results in S3 with metadata

Please provide:
- Complete Terraform modules structure
- Lambda function code templates
- OpenAPI schema for action groups
- IAM policy documents
- Variable definitions and outputs

Use AWS Bedrock Agent best practices and include proper error handling, logging, and monitoring.
```

---

## Implementation Checklist

- [ ] Define complete input/output schemas
- [ ] Create OpenAPI specification for action groups
- [ ] Develop Lambda functions for data generation
- [ ] Set up S3 buckets for data storage
- [ ] Configure DynamoDB for generation history
- [ ] Implement schema validation logic
- [ ] Add compliance checking rules
- [ ] Create data quality metrics calculator
- [ ] Set up knowledge base with patterns
- [ ] Configure CloudWatch monitoring
- [ ] Test with various schema types
- [ ] Document API endpoints
- [ ] Create usage examples
