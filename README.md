# synthetic-data-agent

Primary Goal: Generate realistic, diverse, and compliant synthetic test data for various testing scenarios including functional, performance, and security testing.

## Project Structure

```
synthetic-data-agent/
├── Aidlc-plan/          # Agent planning and design documentation
├── Application/         # Application code and implementation
│   ├── api/            # API specifications and endpoints
│   ├── lambda-functions/ # AWS Lambda function implementations
│   ├── schemas/        # JSON schemas and data type definitions
│   └── utils/          # Utility functions and helpers
├── Infrastructure/      # Infrastructure as Code (IaC)
│   ├── terraform/      # Terraform configurations for AWS resources
│   ├── cloudformation/ # CloudFormation templates
│   └── scripts/        # Deployment and automation scripts
└── README.md           # This file
```

## Getting Started

This project implements an AWS Bedrock Agent for synthetic data generation. For detailed specifications and implementation guidelines, see [Aidlc-plan/synthetic-agent.md](Aidlc-plan/synthetic-agent.md).

### Key Components

- **Aidlc-plan**: Contains the complete agent specification, including role definition, schemas, and implementation checklist
- **Application**: Runtime code for data generation, validation, and quality metrics
- **Infrastructure**: AWS resources configuration using Terraform and CloudFormation
