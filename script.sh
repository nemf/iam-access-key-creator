#!/bin/bash

set -euo pipefail

USER_NAME="bedrock-agent-dev"

# 1. IAM ユーザー作成
aws iam create-user --user-name "$USER_NAME"

# 2. BedrockAgentCoreFullAccess マネージドポリシーをアタッチ
aws iam attach-user-policy \
  --user-name "$USER_NAME" \
  --policy-arn "arn:aws:iam::aws:policy/BedrockAgentCoreFullAccess"

# 3. Bedrock モデル呼び出し + AgentCore starter toolkit 用カスタムポリシー
POLICY_ARN=$(aws iam create-policy \
  --policy-name BedrockAgentCoreDeployPolicy \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "BedrockModelAccess",
        "Effect": "Allow",
        "Action": [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:ListFoundationModels",
          "bedrock:GetFoundationModel"
        ],
        "Resource": "*"
      },
      {
        "Sid": "IAMRoleManagement",
        "Effect": "Allow",
        "Action": [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:TagRole",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ],
        "Resource": [
          "arn:aws:iam::*:role/*BedrockAgentCore*",
          "arn:aws:iam::*:role/service-role/*BedrockAgentCore*"
        ]
      },
      {
        "Sid": "IAMPassRole",
        "Effect": "Allow",
        "Action": "iam:PassRole",
        "Resource": [
          "arn:aws:iam::*:role/AmazonBedrockAgentCore*",
          "arn:aws:iam::*:role/service-role/AmazonBedrockAgentCore*"
        ]
      },
      {
        "Sid": "IAMPolicyForConsole",
        "Effect": "Allow",
        "Action": "iam:CreatePolicy",
        "Resource": "arn:aws:iam::*:policy/service-role/AmazonBedrockAgentCoreRuntimeExecutionPolicy_*"
      },
      {
        "Sid": "CodeBuildAccess",
        "Effect": "Allow",
        "Action": [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:ListBuildsForProject",
          "codebuild:CreateProject",
          "codebuild:UpdateProject",
          "codebuild:BatchGetProjects"
        ],
        "Resource": [
          "arn:aws:codebuild:*:*:project/bedrock-agentcore-*",
          "arn:aws:codebuild:*:*:build/bedrock-agentcore-*"
        ]
      },
      {
        "Sid": "CodeBuildListAccess",
        "Effect": "Allow",
        "Action": "codebuild:ListProjects",
        "Resource": "*"
      },
      {
        "Sid": "ECRRepositoryAccess",
        "Effect": "Allow",
        "Action": [
          "ecr:CreateRepository",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:InitiateLayerUpload",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:ListImages",
          "ecr:TagResource"
        ],
        "Resource": "arn:aws:ecr:*:*:repository/bedrock-agentcore-*"
      },
      {
        "Sid": "ECRAuthAccess",
        "Effect": "Allow",
        "Action": "ecr:GetAuthorizationToken",
        "Resource": "*"
      },
      {
        "Sid": "S3Access",
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:CreateBucket",
          "s3:PutLifecycleConfiguration"
        ],
        "Resource": [
          "arn:aws:s3:::bedrock-agentcore-*",
          "arn:aws:s3:::bedrock-agentcore-*/*"
        ]
      },
      {
        "Sid": "CloudWatchLogsAccess",
        "Effect": "Allow",
        "Action": [
          "logs:GetLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        "Resource": [
          "arn:aws:logs:*:*:log-group:/aws/bedrock-agentcore/*",
          "arn:aws:logs:*:*:log-group:/aws/codebuild/*"
        ]
      }
    ]
  }' \
  --query 'Policy.Arn' --output text)

# 4. カスタムポリシーをアタッチ
aws iam attach-user-policy \
  --user-name "$USER_NAME" \
  --policy-arn "$POLICY_ARN"

# 5. アクセスキー発行
aws iam create-access-key --user-name "$USER_NAME"
