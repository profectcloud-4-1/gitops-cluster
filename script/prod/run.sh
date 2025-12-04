kubectl apply -f base/namespace

kustomize build overlays/prod/secret/sa | kubectl apply -f - || true

helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm upgrade --install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --version 1.1.0 \
  --atomic \
  --set serviceAccount.create=false \
  --set serviceAccount.name=external-secrets-operator \
  --set installCRDs=true \
  --wait --timeout=180s --debug

kustomize build overlays/prod/secret | kubectl apply -f -