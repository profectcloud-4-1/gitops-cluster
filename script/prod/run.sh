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
kustomize build overlays/prod/observability/backend | kubectl apply -f - || true




#
# OTel Collector (뒷단)
#

#
# OTel Collector (앞단)
#

#
# Grafana
#



#
# Ingress
#