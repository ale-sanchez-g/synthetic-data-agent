# Infrastructure

This directory contains infrastructure-as-code (IaC) configurations for deploying the Synthetic Data Generator Agent.

## Purpose

Manages all infrastructure resources including:
- Terraform configurations for AWS Bedrock Agent
- AWS Lambda deployment configurations
- S3 bucket definitions for data storage
- DynamoDB table configurations for generation history
- IAM roles and policies
- CloudWatch monitoring and logging setup
- OpenSearch Serverless for vector store (Knowledge Base)

## Structure

Infrastructure code will be organized by service:
- **Terraform Modules**: Reusable infrastructure modules
- **Lambda Deployment**: Lambda function deployment packages
- **API Schemas**: OpenAPI specifications for action groups
- **Policies**: IAM policy documents and configurations
