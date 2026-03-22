#!/bin/bash
set -euo pipefail

USER_NAME="bedrock-agent-dev"

# 1. IAM ユーザー作成
aws iam create-user --user-name "$USER_NAME"

# 2. カスタムポリシー作成
POLICY_ARN=$(aws iam create-policy \
  --policy-name AIAgentWorkshopPolicy \
  --policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AIAgentWorkshop",
      "Effect": "Allow",
      "Action": [
        "bedrock:*",
        "bedrock-agent:*",
        "bedrock-agentcore:*",
        "aoss:*",
        "lambda:*",
        "s3:*",
        "kms:*",
        "ecr:*",
        "codebuild:*",
        "cloudformation:*",
        "ssm:*",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:GetRolePolicy",
        "iam:ListRoles",
        "iam:TagRole",
        "iam:PassRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:CreatePolicy",
        "iam:GetPolicy",
        "iam:ListPolicies",
        "iam:CreateServiceLinkedRole",
        "iam:UpdateAssumeRolePolicy",
        "logs:*",
        "cloudwatch:*",
        "xray:*",
        "sqs:*",
        "sns:*",
        "dynamodb:*",
        "secretsmanager:*",
        "apigateway:*",
        "execute-api:*",
        "amplify:*",
        "appsync:*",
        "cognito-idp:*",
        "cognito-identity:*",
        "ec2:CreateVpc",
        "ec2:DeleteVpc",
        "ec2:CreateSubnet",
        "ec2:DeleteSubnet",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:CreateVpcEndpoint",
        "ec2:DeleteVpcEndpoints",
        "ec2:CreateInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:AttachInternetGateway",
        "ec2:DetachInternetGateway",
        "ec2:CreateNatGateway",
        "ec2:DeleteNatGateway",
        "ec2:AllocateAddress",
        "ec2:ReleaseAddress",
        "ec2:CreateRouteTable",
        "ec2:DeleteRouteTable",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:AssociateRouteTable",
        "ec2:DisassociateRouteTable",
        "ec2:ModifyVpcAttribute",
        "ec2:Describe*",
        "sts:AssumeRole",
        "sts:TagSession",
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyDangerousActions",
      "Effect": "Deny",
      "Action": [
        "organizations:*",
        "account:*",
        "iam:CreateUser",
        "iam:CreateAccessKey",
        "iam:DeactivateMFADevice",
        "iam:DeleteAccountPasswordPolicy",
        "ec2:RunInstances",
        "ec2:RequestSpotInstances",
        "sagemaker:CreateNotebookInstance",
        "sagemaker:CreateTrainingJob"
      ],
      "Resource": "*"
    }
  ]
}' \
  --query 'Policy.Arn' --output text)

# 3. カスタムポリシーをアタッチ
aws iam attach-user-policy \
  --user-name "$USER_NAME" \
  --policy-arn "$POLICY_ARN"

# 4. アクセスキー発行
aws iam create-access-key --user-name "$USER_NAME"
