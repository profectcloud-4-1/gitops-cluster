#!/usr/bin/env bash
set -e

CLUSTER_NAME="goorm"
REGION="ap-northeast-2"
PROFILE="staging" # 기본=default. 현재 aws cli에 staging이라는 프로필을 등록되어 있어 이걸 사용합니다.

VPC_ID=$(aws ec2 describe-vpcs \
  --region "$REGION" \
  --filters "Name=tag:kubernetes.io/cluster/${CLUSTER_NAME},Values=shared" \
  --query "Vpcs[0].VpcId" \
  --output text \
  --profile "$PROFILE")

if [ "$VPC_ID" = "None" ] || [ -z "$VPC_ID" ]; then
  echo "Error: No VPC found with tag kubernetes.io/cluster/${CLUSTER_NAME}=shared"
  exit 1
fi

echo "$VPC_ID"