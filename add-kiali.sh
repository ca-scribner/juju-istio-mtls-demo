# Deploys kiali, so you can visualise the traffic on the istio service mesh better

# Prometheus needed for kiali
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/prometheus.yaml

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/kiali.yaml

# Wait for it to roll out successfully
kubectl rollout status deployment -n istio-system kiali --timeout=90s
kubectl rollout status deployment -n istio-system prometheus --timeout=90s

echo
echo "To see the kiali dashboard, use 'istioctl dashboard kiali'"
