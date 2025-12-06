#!/bin/bash

kubectl apply -f base/namespace


# 
# ESO
#

# kustomize build overlays/prod/secret/sa | kubectl apply -f - || true

# helm repo add external-secrets https://charts.external-secrets.io
# helm repo update
# helm upgrade --install external-secrets external-secrets/external-secrets \
#   --namespace external-secrets \
#   --version 1.1.0 \
#   --atomic \
#   --set serviceAccount.create=false \
#   --set serviceAccount.name=external-secrets-operator \
#   --set installCRDs=true \
#   --wait --timeout=180s --debug

# kustomize build overlays/prod/secret | kubectl apply -f -

# 
# OTel Operator
# 
# helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
# helm upgrade --install otel-operator open-telemetry/opentelemetry-operator \
#   --namespace observability \
#   --set "manager.collectorImage.repository=otel/opentelemetry-collector-k8s" \
#   --set admissionWebhooks.certManager.enabled=false \
#   --set admissionWebhooks.autoGenerateCert.enabled=true \
#   --wait --timeout=180s

#
# Telemetry Backend
#

# SA
kustomize build overlays/prod/observability/sa | kubectl apply -f - || true

# Tempo
# helm repo add grafana https://grafana.github.io/helm-charts
# helm repo update
# helm upgrade --install tempo grafana/tempo \
#   --namespace observability \
#   --create-namespace=false \
#   --version 1.10.0 \
#   --wait --timeout 180s \
#   --atomic \
#   -f overlays/prod/observability/backend/tempo/values.yaml

# Loki
# helm upgrade --install loki grafana/loki \
#   --namespace observability \
#   --create-namespace=false \
#   --version 6.46.0 \
#   --wait --timeout 180s \
#   --atomic \
#   -f overlays/prod/observability/backend/loki/values.yaml

# Mimir
# kustomize build overlays/prod/observability/backend | kubectl apply -f - || true

#
# Grafana
#
helm upgrade --install grafana grafana/grafana \
  --namespace observability \
  --create-namespace=false \
  --version 10.3.0 \
  --wait --timeout 180s \
  --atomic \
  -f overlays/prod/observability/grafana/values.yaml

#
# OTel Collector (뒷단)
#
# kustomize build overlays/prod/observability/collector/secret | kubectl apply -f - || true
# kustomize build overlays/prod/observability/collector/consumer | kubectl apply -f - || true


#
# OTel Collector (앞단)
#
# kubectl apply -f base/observability/collector/producer/serviceaccount.yaml || true
# kubectl apply -f base/observability/collector/producer/rbac.yaml || true
# kubectl apply -f base/observability/collector/producer/otel-collector.yaml || true

#
# Ingress
#

# SA
# kubectl apply -f overlays/prod/ingress/sa/sa.yaml || true

# Ingress Controller
# helm repo add eks https://aws.github.io/eks-charts
# helm repo update

# VPC_ID=$(./script/shared/get_vpc_id.sh)
# echo "VPC_ID: $VPC_ID"

# helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
#   --namespace kube-system \
#   --create-namespace=false \
#   --version 1.16.0 \
#   --wait --timeout 5m \
#   --atomic \
#   --set vpcId=$VPC_ID \
#   -f overlays/prod/ingress/ingress-controller/values.yaml

# Ingress
# kustomize build overlays/prod/ingress | kubectl apply -f - || true

#
# ArgoCD & AppliationSet
#
# helm repo add argo https://argoproj.github.io/argo-helm
# helm repo update
# helm upgrade --install argocd argo/argo-cd \
#   --namespace argocd \
#   --create-namespace=false \
#   --version 9.1.6 \
#   --set configs.cm.timeout.reconciliation=30s \
#   --wait --timeout 180s

# # ApplicationSet
# kustomize build overlays/prod/argocd/msa | kubectl apply -f - || true