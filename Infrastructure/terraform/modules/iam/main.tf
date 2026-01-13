# ============================================================================
# IAM Module
# ============================================================================
# This module manages IAM roles and policies for:
# - Bedrock Agent execution role
# - Lambda function execution role
# - Knowledge Base role
# All roles follow least privilege principle
# ============================================================================

terraform {
  required_version = ">= 1.6.0"
}

# Local variables
locals {
  bedrock_agent_role_name    = "${var.project_name}-${var.environment}-bedrock-agent-role"
  lambda_execution_role_name = "${var.project_name}-${var.environment}-lambda-role"
  knowledge_base_role_name   = "${var.project_name}-${var.environment}-kb-role"
}

# ============================================================================
# Data Sources
# ============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ============================================================================
# Bedrock Agent IAM Role
# ============================================================================

resource "aws_iam_role" "bedrock_agent" {
  name               = local.bedrock_agent_role_name
  assume_role_policy = data.aws_iam_policy_document.bedrock_agent_trust.json
  description        = "Execution role for Bedrock Agent - ${var.environment} environment"

  tags = merge(
    var.tags,
    {
      Name        = local.bedrock_agent_role_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "BedrockAgent"
    }
  )
}

# Trust policy for Bedrock Agent
data "aws_iam_policy_document" "bedrock_agent_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:agent/*"]
    }
  }
}

# Bedrock Agent policy for Lambda invocation
resource "aws_iam_role_policy" "bedrock_agent_lambda" {
  name   = "${local.bedrock_agent_role_name}-lambda-policy"
  role   = aws_iam_role.bedrock_agent.id
  policy = data.aws_iam_policy_document.bedrock_agent_lambda.json
}

data "aws_iam_policy_document" "bedrock_agent_lambda" {
  statement {
    sid    = "InvokeLambdaFunctions"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.project_name}-${var.environment}-*"
    ]
  }
}

# Bedrock Agent policy for Knowledge Base access
resource "aws_iam_role_policy" "bedrock_agent_kb" {
  count  = var.opensearch_collection_arn != null && var.opensearch_collection_arn != "" ? 1 : 0
  name   = "${local.bedrock_agent_role_name}-kb-policy"
  role   = aws_iam_role.bedrock_agent.id
  policy = data.aws_iam_policy_document.bedrock_agent_kb[0].json
}

data "aws_iam_policy_document" "bedrock_agent_kb" {
  count = var.opensearch_collection_arn != null && var.opensearch_collection_arn != "" ? 1 : 0

  statement {
    sid    = "RetrieveKnowledgeBase"
    effect = "Allow"
    actions = [
      "bedrock:Retrieve",
      "bedrock:RetrieveAndGenerate"
    ]
    resources = [
      "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
    ]
  }
}

# Bedrock Agent policy for foundation model access
resource "aws_iam_role_policy" "bedrock_agent_model" {
  name   = "${local.bedrock_agent_role_name}-model-policy"
  role   = aws_iam_role.bedrock_agent.id
  policy = data.aws_iam_policy_document.bedrock_agent_model.json
}

data "aws_iam_policy_document" "bedrock_agent_model" {
  statement {
    sid    = "InvokeFoundationModel"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel"
    ]
    resources = [
      "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/*"
    ]
  }
}

# ============================================================================
# Lambda Execution IAM Role
# ============================================================================

resource "aws_iam_role" "lambda_execution" {
  name               = local.lambda_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
  description        = "Execution role for Lambda functions - ${var.environment} environment"

  tags = merge(
    var.tags,
    {
      Name        = local.lambda_execution_role_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "Lambda"
    }
  )
}

# Trust policy for Lambda
data "aws_iam_policy_document" "lambda_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# Attach AWS managed policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda policy for S3 access
resource "aws_iam_role_policy" "lambda_s3" {
  count  = length(var.s3_bucket_arns) > 0 && alltrue([for arn in var.s3_bucket_arns : arn != null && arn != ""]) ? 1 : 0
  name   = "${local.lambda_execution_role_name}-s3-policy"
  role   = aws_iam_role.lambda_execution.id
  policy = data.aws_iam_policy_document.lambda_s3[0].json
}

data "aws_iam_policy_document" "lambda_s3" {
  count = length(var.s3_bucket_arns) > 0 && alltrue([for arn in var.s3_bucket_arns : arn != null && arn != ""]) ? 1 : 0

  statement {
    sid    = "S3BucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = concat(
      var.s3_bucket_arns,
      [for arn in var.s3_bucket_arns : "${arn}/*"]
    )
  }
}

# Lambda policy for DynamoDB access
resource "aws_iam_role_policy" "lambda_dynamodb" {
  count  = var.dynamodb_table_arn != null && var.dynamodb_table_arn != "" ? 1 : 0
  name   = "${local.lambda_execution_role_name}-dynamodb-policy"
  role   = aws_iam_role.lambda_execution.id
  policy = data.aws_iam_policy_document.lambda_dynamodb[0].json
}

data "aws_iam_policy_document" "lambda_dynamodb" {
  count = var.dynamodb_table_arn != null && var.dynamodb_table_arn != "" ? 1 : 0

  statement {
    sid    = "DynamoDBAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem"
    ]
    resources = [
      var.dynamodb_table_arn,
      "${var.dynamodb_table_arn}/index/*"
    ]
  }
}

# Lambda policy for KMS access
resource "aws_iam_role_policy" "lambda_kms" {
  count  = length(var.kms_key_arns) > 0 ? 1 : 0
  name   = "${local.lambda_execution_role_name}-kms-policy"
  role   = aws_iam_role.lambda_execution.id
  policy = data.aws_iam_policy_document.lambda_kms[0].json
}

data "aws_iam_policy_document" "lambda_kms" {
  count = length(var.kms_key_arns) > 0 ? 1 : 0

  statement {
    sid    = "KMSAccess"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = var.kms_key_arns
  }
}

# ============================================================================
# Knowledge Base IAM Role
# ============================================================================

resource "aws_iam_role" "knowledge_base" {
  name               = local.knowledge_base_role_name
  assume_role_policy = data.aws_iam_policy_document.knowledge_base_trust.json
  description        = "Execution role for Bedrock Knowledge Base - ${var.environment} environment"

  tags = merge(
    var.tags,
    {
      Name        = local.knowledge_base_role_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "KnowledgeBase"
    }
  )
}

# Trust policy for Knowledge Base
data "aws_iam_policy_document" "knowledge_base_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"]
    }
  }
}

# Knowledge Base policy for S3 access
resource "aws_iam_role_policy" "knowledge_base_s3" {
  count  = length(var.s3_bucket_arns) > 0 && alltrue([for arn in var.s3_bucket_arns : arn != null && arn != ""]) ? 1 : 0
  name   = "${local.knowledge_base_role_name}-s3-policy"
  role   = aws_iam_role.knowledge_base.id
  policy = data.aws_iam_policy_document.knowledge_base_s3[0].json
}

data "aws_iam_policy_document" "knowledge_base_s3" {
  count = length(var.s3_bucket_arns) > 0 && alltrue([for arn in var.s3_bucket_arns : arn != null && arn != ""]) ? 1 : 0

  statement {
    sid    = "S3ReadAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = concat(
      var.s3_bucket_arns,
      [for arn in var.s3_bucket_arns : "${arn}/*"]
    )
  }
}

# Knowledge Base policy for OpenSearch access
resource "aws_iam_role_policy" "knowledge_base_opensearch" {
  count  = var.opensearch_collection_arn != null && var.opensearch_collection_arn != "" ? 1 : 0
  name   = "${local.knowledge_base_role_name}-opensearch-policy"
  role   = aws_iam_role.knowledge_base.id
  policy = data.aws_iam_policy_document.knowledge_base_opensearch[0].json
}

data "aws_iam_policy_document" "knowledge_base_opensearch" {
  count = var.opensearch_collection_arn != null && var.opensearch_collection_arn != "" ? 1 : 0

  statement {
    sid    = "OpenSearchAccess"
    effect = "Allow"
    actions = [
      "aoss:APIAccessAll"
    ]
    resources = [var.opensearch_collection_arn]
  }
}

# Knowledge Base policy for embedding model access
resource "aws_iam_role_policy" "knowledge_base_model" {
  name   = "${local.knowledge_base_role_name}-model-policy"
  role   = aws_iam_role.knowledge_base.id
  policy = data.aws_iam_policy_document.knowledge_base_model.json
}

data "aws_iam_policy_document" "knowledge_base_model" {
  statement {
    sid    = "InvokeEmbeddingModel"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel"
    ]
    resources = [
      "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v1"
    ]
  }
}
