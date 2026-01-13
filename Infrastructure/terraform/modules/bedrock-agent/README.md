# Bedrock Agent Module

This module manages AWS Bedrock Agent resources for the Synthetic Data Generator Agent.

## Features

- **Bedrock Agent**: Creates an agent powered by Claude 3 Sonnet foundation model
- **Action Groups**: Configures action groups linking to Lambda functions for data generation operations
- **Agent Alias**: Creates a LIVE alias for the agent deployment
- **Knowledge Base Integration**: Optional association with Bedrock Knowledge Base for RAG capabilities

## Resources Created

1. `aws_bedrockagent_agent.main` - The main Bedrock Agent
2. `aws_bedrockagent_agent_action_group.data_generation` - Action group for synthetic data operations
3. `aws_bedrockagent_agent_knowledge_base_association.main` - Knowledge base association (optional)
4. `aws_bedrockagent_agent_alias.live` - Agent alias for deploymentfile## Usage

```hcl
module "bedrock_agent" {
  source = "./modules/bedrock-agent"

  project_name = "sdga"
  environment  = "dev"

  # Agent configuration
  agent_name        = "synthetic-data-generator"
  foundation_model  = "anthropic.claude-3-sonnet-20240229-v1:0"
  agent_instruction = file("path/to/instructions.txt")
  idle_session_ttl  = 600

  # Knowledge base (optional)
  knowledge_base_id = "KB123456"

  # Action group Lambda functions
  lambda_function_arns = {
    generate_synthetic_data = "arn:aws:lambda:us-east-1:123456789012:function:generate"
    validate_schema         = "arn:aws:lambda:us-east-1:123456789012:function:validate"
    calculate_quality_metrics = "arn:aws:lambda:us-east-1:123456789012:function:metrics"
  }

  # IAM role
  execution_role_arn = "arn:aws:iam::123456789012:role/bedrock-agent-role"

  tags = {
    Environment = "dev"
    Project     = "synthetic-data-agent"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Project name | `string` | n/a | yes |
| environment | Environment name (dev/stg/prod) | `string` | n/a | yes |
| agent_name | Name of the Bedrock Agent | `string` | n/a | yes |
| foundation_model | Foundation model ID | `string` | n/a | yes |
| agent_instruction | Agent instructions defining behavior | `string` | n/a | yes |
| idle_session_ttl | Idle session timeout in seconds | `number` | `600` | no |
| execution_role_arn | IAM execution role ARN for the agent | `string` | n/a | yes |
| knowledge_base_id | Knowledge Base ID for RAG | `string` | `""` | no |
| lambda_function_arns | Map of Lambda function ARNs for action groups | `map(string)` | `{}` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| agent_id | The ID of the Bedrock Agent |
| agent_arn | The ARN of the Bedrock Agent |
| agent_name | The name of the Bedrock Agent |
| agent_version | The version of the Bedrock Agent |
| agent_alias_id | The ID of the agent alias |
| agent_alias_arn | The ARN of the agent alias |
| action_group_id | The ID of the action group |
| action_group_name | The name of the action group |

## Agent Instructions

The module includes comprehensive agent instructions in `agent-instructions.txt` that define:

- Core responsibilities for synthetic data generation
- Behavioral guidelines for validation and quality assurance
- Error handling and recovery procedures
- Communication style and output formatting
- Available actions and their usage
- Context retention and memory management

## OpenAPI Schema

The module includes a complete OpenAPI 3.0 specification (`openapi-schema.json`) defining three endpoints:

1. **/generate-synthetic-data**: Generate synthetic test data
2. **/validate-schema**: Validate data schemas
3. **/calculate-quality-metrics**: Analyze data quality

Each endpoint includes:
- Request/response schemas
- Field definitions and constraints
- Validation rules
- Error responses
- Compliance requirements (GDPR, HIPAA, PCI-DSS, SOC2, CCPA)

## Dependencies

This module requires:

1. **IAM Module**: Must create the Bedrock Agent execution role with proper permissions
2. **Lambda Module**: Must create the three Lambda functions for action groups
3. **Knowledge Base Module** (optional): For RAG capabilities

## Action Group Integration

The action group connects the Bedrock Agent to three Lambda functions:

- `generate_synthetic_data`: Creates synthetic datasets based on schema definitions
- `validate_schema`: Validates schema correctness before generation
- `calculate_quality_metrics`: Analyzes generated data quality

The OpenAPI schema defines the interface contract between the agent and these functions.

## Security Considerations

- The execution role must have permissions to:
  - Invoke Lambda functions
  - Access Knowledge Base (if configured)
  - Write to CloudWatch Logs
- Agent instructions should not include sensitive information
- Follow AWS Well-Architected Framework security best practices

## Cost Considerations

- **Bedrock Agent**: Charged per request based on model tokens
- **Foundation Model (Claude 3 Sonnet)**: Input/output tokens pricing
- **Knowledge Base**: Storage and query costs (if used)
- Typical dev environment: ~$10-20/month for moderate usage

## Limitations

- Agent must be prepared after changes (automatic with `prepare_agent = true`)
- Action groups require Lambda functions to exist before association
- Knowledge base must be created before association
- Agent alias cannot be updated without recreation

## Troubleshooting

### Agent not responding
- Check execution role permissions
- Verify Lambda functions are deployed and accessible
- Review CloudWatch Logs for errors
- Ensure foundation model is available in the region

### Action group failures
- Verify Lambda function ARNs are correct
- Check Lambda execution role permissions
- Validate OpenAPI schema syntax
- Test Lambda functions independently

### Knowledge base issues
- Ensure Knowledge Base is created and synced
- Verify S3 bucket permissions
- Check OpenSearch collection accessibility
- Review data source configuration

## Examples

### Basic Agent (No Knowledge Base)

```hcl
module "bedrock_agent" {
  source = "./modules/bedrock-agent"

  project_name      = "sdga"
  environment       = "dev"
  agent_name        = "synthetic-data-generator"
  foundation_model  = "anthropic.claude-3-sonnet-20240229-v1:0"
  
  execution_role_arn = module.iam.bedrock_agent_role_arn
  
  lambda_function_arns = {
    generate_synthetic_data = module.lambda.generate_function_arn
  }
}
```

### Agent with Knowledge Base

```hcl
module "bedrock_agent" {
  source = "./modules/bedrock-agent"

  project_name      = "sdga"
  environment       = "prod"
  agent_name        = "synthetic-data-generator"
  foundation_model  = "anthropic.claude-3-sonnet-20240229-v1:0"
  
  execution_role_arn = module.iam.bedrock_agent_role_arn
  knowledge_base_id  = module.bedrock_knowledge_base.knowledge_base_id
  
  lambda_function_arns = {
    generate_synthetic_data    = module.lambda.generate_function_arn
    validate_schema            = module.lambda.validate_function_arn
    calculate_quality_metrics  = module.lambda.metrics_function_arn
  }
  
  idle_session_ttl = 900
  
  tags = {
    Environment = "prod"
    Critical    = "true"
  }
}
```

## Testing

To test the module:

```bash
# Validate configuration
terraform validate

# Plan deployment
terraform plan -var-file=environments/dev.tfvars

# Apply changes
terraform apply -var-file=environments/dev.tfvars

# Test agent invocation (AWS CLI)
aws bedrock-agent invoke-agent \
  --agent-id <agent-id> \
  --agent-alias-id <alias-id> \
  --session-id test-session-1 \
  --input-text "Generate 100 user profiles"
```

## References

- [AWS Bedrock Agent Documentation](https://docs.aws.amazon.com/bedrock/latest/userguide/agents.html)
- [OpenAPI 3.0 Specification](https://swagger.io/specification/)
- [Claude 3 Sonnet Model Card](https://www.anthropic.com/claude)

---

**Version**: 1.0  
**Last Updated**: January 13, 2026  
**Maintained By**: DevOps Team
