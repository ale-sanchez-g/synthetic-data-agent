# Testing Guide - Synthetic Data Generator Agent

## Quick Reference for Testing Infrastructure

### Current Deployment Status

**Environment**: dev  
**Agent ID**: NVWOHTF4ZZ  
**Agent Alias ID**: YIQDRAV17J  
**AWS Region**: us-east-1  
**AWS Account**: 060367163877

---

## 1. Verify IAM Roles

### Check Role Existence
```bash
# Bedrock Agent Role
aws iam get-role --role-name sdga-dev-bedrock-agent-role --region us-east-1

# Lambda Execution Role
aws iam get-role --role-name sdga-dev-lambda-role --region us-east-1

# Knowledge Base Role
aws iam get-role --role-name sdga-dev-kb-role --region us-east-1
```

### List Role Policies
```bash
# Bedrock Agent Role policies
aws iam list-role-policies --role-name sdga-dev-bedrock-agent-role --region us-east-1

# Lambda Role policies
aws iam list-role-policies --role-name sdga-dev-lambda-role --region us-east-1

# Knowledge Base Role policies
aws iam list-role-policies --role-name sdga-dev-kb-role --region us-east-1
```

### Get Specific Policy
```bash
# Get Bedrock Agent Lambda policy
aws iam get-role-policy \
  --role-name sdga-dev-bedrock-agent-role \
  --policy-name sdga-dev-bedrock-agent-role-lambda-policy \
  --region us-east-1
```

---

## 2. Verify Bedrock Agent

### Get Agent Details
```bash
# Get agent information
aws bedrock-agent get-agent \
  --agent-id NVWOHTF4ZZ \
  --region us-east-1
```

### List Agent Aliases
```bash
# List all aliases for the agent
aws bedrock-agent list-agent-aliases \
  --agent-id NVWOHTF4ZZ \
  --region us-east-1
```

### Get Agent Alias
```bash
# Get specific alias details
aws bedrock-agent get-agent-alias \
  --agent-id NVWOHTF4ZZ \
  --agent-alias-id YIQDRAV17J \
  --region us-east-1
```

### List Action Groups
```bash
# List action groups (currently none until Lambda is deployed)
aws bedrock-agent list-agent-action-groups \
  --agent-id NVWOHTF4ZZ \
  --agent-version DRAFT \
  --region us-east-1
```

---

## 3. Test Bedrock Agent (After Lambda Deployment)

### Interactive Test via Console
1. Navigate to AWS Console: https://console.aws.amazon.com/bedrock/
2. Go to **Agents** section
3. Select agent: `sdga-dev-agent` (NVWOHTF4ZZ)
4. Click on **Test** tab
5. Use the chat interface to test

### Test via AWS CLI

#### Basic Invocation
```bash
# Simple test query
aws bedrock-agent-runtime invoke-agent \
  --agent-id NVWOHTF4ZZ \
  --agent-alias-id YIQDRAV17J \
  --session-id test-$(date +%s) \
  --input-text "What can you do?" \
  --region us-east-1 \
  --output-stream /dev/stdout
```

#### Test Data Generation (After Lambda Deployment)
```bash
# Generate synthetic data
aws bedrock-agent-runtime invoke-agent \
  --agent-id NVWOHTF4ZZ \
  --agent-alias-id YIQDRAV17J \
  --session-id test-generate-$(date +%s) \
  --input-text "Generate 5 synthetic user profiles for QA testing" \
  --region us-east-1 \
  --output-stream /dev/stdout
```

#### Test Schema Validation (After Lambda Deployment)
```bash
# Validate schema
aws bedrock-agent-runtime invoke-agent \
  --agent-id NVWOHTF4ZZ \
  --agent-alias-id YIQDRAV17J \
  --session-id test-validate-$(date +%s) \
  --input-text "Validate this schema: {\"type\": \"user_profile\", \"fields\": [\"name\", \"email\"]}" \
  --region us-east-1 \
  --output-stream /dev/stdout
```

### Test with Python SDK (boto3)

```python
import boto3
import json

# Initialize Bedrock Agent Runtime client
client = boto3.client('bedrock-agent-runtime', region_name='us-east-1')

# Invoke agent
response = client.invoke_agent(
    agentId='NVWOHTF4ZZ',
    agentAliasId='YIQDRAV17J',
    sessionId='test-session-python',
    inputText='Generate 10 synthetic transaction records'
)

# Process streaming response
for event in response['completion']:
    if 'chunk' in event:
        chunk = event['chunk']
        if 'bytes' in chunk:
            print(chunk['bytes'].decode('utf-8'), end='')
```

---

## 4. Terraform Operations

### Plan Changes
```bash
cd /Users/alejandrosanchez-giraldo/git/synthetic-data-agent/Infrastructure/terraform
./scripts/plan.sh dev
```

### Apply Changes
```bash
# With plan file
./scripts/deploy.sh dev tfplan-dev

# Or directly (with confirmation)
terraform apply -lock=false
```

### Destroy Resources
```bash
# Interactive destroy
./scripts/destroy.sh dev

# Or directly (requires confirmation)
terraform destroy -lock=false
```

### Validate Configuration
```bash
./scripts/validate.sh
# or
terraform validate
```

### View Current State
```bash
# Show all resources
terraform show

# Show specific resource
terraform show module.bedrock_agent.aws_bedrockagent_agent.main

# List all resources
terraform state list

# Show specific state
terraform state show module.iam.aws_iam_role.bedrock_agent
```

### View Outputs
```bash
# All outputs
terraform output

# Specific output
terraform output bedrock_agent_id
terraform output bedrock_agent_arn
terraform output bedrock_agent_role_arn
```

---

## 5. Debugging

### Check Terraform Logs
```bash
# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform-debug.log

# Run operation
terraform plan -lock=false

# View logs
tail -f terraform-debug.log
```

### Check AWS CloudTrail
```bash
# Get recent Bedrock events
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceType,AttributeValue=AWS::Bedrock::Agent \
  --region us-east-1 \
  --max-results 50
```

### Check IAM Role Trust Relationships
```bash
# Get role trust policy
aws iam get-role \
  --role-name sdga-dev-bedrock-agent-role \
  --query 'Role.AssumeRolePolicyDocument' \
  --region us-east-1
```

### Validate IAM Policies
```bash
# Simulate policy
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::060367163877:role/sdga-dev-bedrock-agent-role \
  --action-names bedrock:InvokeModel lambda:InvokeFunction \
  --region us-east-1
```

---

## 6. Expected Errors (Before Full Deployment)

### Action Group Not Available
**Error**: No action groups found  
**Reason**: Lambda functions not yet deployed (Task 3.x not complete)  
**Solution**: Complete Tasks 3.1-3.4 to deploy Lambda functions

### Knowledge Base Association Missing
**Error**: No knowledge base associated  
**Reason**: Knowledge Base not yet created (Task 5.x not complete)  
**Solution**: Complete Task 5.1-5.3 to create Knowledge Base

### Agent Cannot Process Requests
**Error**: Agent responds but cannot execute actions  
**Reason**: Action groups require Lambda functions  
**Solution**: Deploy Lambda functions, then retest

---

## 7. Success Criteria

### ✅ IAM Roles Created
- [ ] Bedrock Agent role exists with ARN
- [ ] Lambda execution role exists with ARN
- [ ] Knowledge Base role exists with ARN
- [ ] All roles have proper trust policies
- [ ] All roles have required permissions

### ✅ Bedrock Agent Deployed
- [ ] Agent exists with ID and ARN
- [ ] Agent has LIVE alias
- [ ] Agent uses Claude 3 Sonnet model
- [ ] Agent has proper IAM role attached
- [ ] Agent can be invoked via API/CLI

### ⏸️ Action Groups Configured (BLOCKED)
- [ ] Action group exists for data generation
- [ ] Lambda functions linked to action groups
- [ ] OpenAPI schema validated
- [ ] Agent can execute actions

### ⏸️ Knowledge Base Associated (NOT STARTED)
- [ ] Knowledge Base created
- [ ] Knowledge Base associated with agent
- [ ] Agent can query knowledge base
- [ ] Test data available in knowledge base

---

## 8. Next Steps

1. **Implement Lambda Base Module (Task 3.1)**
   ```bash
   # After implementation
   cd Infrastructure/terraform
   ./scripts/plan.sh dev
   ./scripts/deploy.sh dev
   ```

2. **Deploy Lambda Functions (Tasks 3.2-3.4)**
   ```bash
   # Test Lambda directly
   aws lambda invoke \
     --function-name sdga-dev-generate-synthetic-data \
     --payload '{"data_type": "user_profile", "count": 5}' \
     --region us-east-1 \
     output.json
   ```

3. **Link Action Groups to Lambda**
   ```bash
   # Verify action group after linking
   aws bedrock-agent list-agent-action-groups \
     --agent-id NVWOHTF4ZZ \
     --agent-version DRAFT \
     --region us-east-1
   ```

4. **Test End-to-End Workflow**
   ```bash
   # Full agent test
   aws bedrock-agent-runtime invoke-agent \
     --agent-id NVWOHTF4ZZ \
     --agent-alias-id YIQDRAV17J \
     --session-id e2e-test-$(date +%s) \
     --input-text "Generate 10 synthetic user profiles with GDPR compliance" \
     --region us-east-1
   ```

---

## 9. Useful AWS Console Links

- **Bedrock Agents**: https://console.aws.amazon.com/bedrock/home?region=us-east-1#/agents
- **IAM Roles**: https://console.aws.amazon.com/iamv2/home?region=us-east-1#/roles
- **Lambda Functions**: https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions
- **CloudWatch Logs**: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups
- **S3 Buckets**: https://s3.console.aws.amazon.com/s3/buckets?region=us-east-1

---

## 10. Troubleshooting

### Agent Not Responding
1. Check agent status: `aws bedrock-agent get-agent --agent-id NVWOHTF4ZZ`
2. Verify IAM role exists and has permissions
3. Check CloudWatch logs (after logging is configured)
4. Verify foundation model access in region

### IAM Permission Errors
1. Check role trust policy
2. Verify policy attachments
3. Simulate policy permissions
4. Review CloudTrail for access denied events

### Terraform State Issues
1. Check S3 backend connectivity
2. Verify AWS credentials
3. Try refresh: `terraform refresh -lock=false`
4. Check state file: `aws s3 ls s3://sdga-infra-tfstate-dev-backend/`

---

**Last Updated**: January 13, 2026  
**Environment**: dev  
**Status**: Base infrastructure deployed, Lambda functions pending
