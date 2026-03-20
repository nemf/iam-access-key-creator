#!/bin/bash

# 1. IAM ユーザー作成
aws iam create-user --user-name bedrock-agent-dev

# 2. ポリシー作成
POLICY_ARN=$(aws iam create-policy \
  --policy-name BedrockAgentDevPolicy \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "bedrock:*",
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": ["iam:CreateRole","iam:AttachRolePolicy","iam:PassRole","iam:GetRole"],
        "Resource": "arn:aws:iam::*:role/bedrock-*"
      }
    ]
  }' \
  --query 'Policy.Arn' --output text)

# 3. ポリシーをアタッチ
aws iam attach-user-policy \
  --user-name bedrock-agent-dev \
  --policy-arn "$POLICY_ARN"

# 4. アクセスキー発行
aws iam create-access-key --user-name bedrock-agent-dev
