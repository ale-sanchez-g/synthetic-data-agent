# Infrastructure

This directory contains infrastructure as code (IaC) for deploying and managing the Synthetic Data Generator Agent.

## Structure

- **terraform/**: Terraform configurations for AWS Bedrock Agent, Lambda, S3, DynamoDB, and other AWS services
- **cloudformation/**: CloudFormation templates (alternative to Terraform)
- **scripts/**: Deployment and automation scripts

## Purpose

The Infrastructure folder contains all resources needed to provision and manage:
- AWS Bedrock Agent configuration
- Lambda functions and their dependencies
- S3 buckets for data storage
- DynamoDB tables for generation history
- IAM roles and policies
- CloudWatch monitoring and logging
- OpenSearch Serverless for knowledge base
