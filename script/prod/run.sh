#!/bin/bash

kubectl apply -f base/namespace

#
# Cert Manager
#
# helm upgrade --install cert-manager \
#   oci://quay.io/jetstack/charts/cert-manager \
#   --version v1.19.1 \
#   --namespace cert-manager \
#   --create-namespace=false \
#   -f base/cert-manager/values.yaml \
#   --wait --timeout 180s \
#   --atomic

#
# Metrics Server
#
# helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
# helm repo update

# helm upgrade --install metrics-server metrics-server/metrics-server \
#   --version 3.13.0 \
#   --namespace kube-system \
#   --create-namespace=false \
#   --wait --timeout 180s \
#   --atomic \
#   -f base/metrics-server/values.yaml

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
#   -f base/secret/eso/values.yaml \
#   --wait --timeout=180s --debug

# kustomize build overlays/prod/secret | kubectl apply -f -

# 
# OTel Operator
# 
# helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
# helm upgrade --install otel-operator open-telemetry/opentelemetry-operator \
#   --namespace observability \
#   --create-namespace=false \
#   --version 0.99.2 \
#   -f base/observability/otel-operator/values.yaml \
#   --atomic \
#   --wait --timeout=180s

# NOTE: operator 설치 시 함께 설치되는 'opentelemetrycollectors.opentelemetry.io' 라는 CRD의 'cert-manager.io/inject-ca-from' 어노테이션에 "namespace/secret-name" 형식의 값이 들어가야 하는데, operator는 'none'이라고 적어놨음. 이거땜에 cert-manager가 터져서 operator crd의 해당 어노테이션 값을 제거함.
# kubectl patch crd opentelemetrycollectors.opentelemetry.io \
#   --type=json \
#   -p '[{"op": "remove", "path": "/metadata/annotations/cert-manager.io~1inject-ca-from"}]'

#
# Telemetry Backend
#

# SA
# kustomize build overlays/prod/observability/sa | kubectl apply -f - || true

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
# helm upgrade --install grafana grafana/grafana \
#   --namespace observability \
#   --create-namespace=false \
#   --version 10.3.0 \
#   --wait --timeout 180s \
#   --atomic \
#   -f overlays/prod/observability/grafana/values.yaml

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
# kubectl apply -f base/observability/collector/system || true

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
#   --version 1.14.1 \
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
#   -f base/argocd/values.yaml \
#   --wait --timeout 180s

# # ApplicationSet
# kustomize build overlays/prod/argocd/msa | kubectl apply -f - || true
# kubectl apply -f base/argocd/msa/application-auth.yaml

#
# Stakater Reloader
#
# helm repo add stakater https://stakater.github.io/stakater-charts
# helm repo update
# helm upgrade --install reloader stakater/reloader \
#   --namespace reloader \
#   --create-namespace=false \
#   --version 2.2.5 \
#   --wait --timeout 180s \
#   --atomic \
#   -f base/reloader/values.yaml
