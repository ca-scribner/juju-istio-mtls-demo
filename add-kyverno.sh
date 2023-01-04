### Kyverno
# Deploy Kyverno, which is used to mutate all namespaces to include the istio-injection=enabled label (unless they have a label of kyverno=disabled)
kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/main/config/install.yaml

# Wait for it to roll out successfully
kubectl rollout status deployment -n kyverno kyverno --timeout=90s

# Add a rule that mutates all pods to have "istio-injection=enabled", unless they're 
# excluded by label "kyverno=disabled"
kubectl apply -n default -f add-sidecar-injection-namespace-kyverno-with-exceptions.yaml

echo "Sleeping 15s to let Kyverno settle in (there seems to be a race condition here if I create namespaces right after this)"
sleep 15

# # Test Kyverno
# kubectl create namespace test-kyverno-adds-injection
# kubectl get namespace test-kyverno-adds-injection -o jsonpath='{.metadata.labels}' | jq 
# # Which will include '"istio-injection": "enabled"'

# kubectl apply -f - <<EOF
# apiVersion: v1
# kind: Namespace
# metadata:
#   labels:
#     kyverno: disabled
#   name: test-kyverno-no-injection
# EOF
# kubectl get namespace test-kyverno-no-injection -o jsonpath='{.metadata.labels}' | jq 
# # Which will NOT include '"istio-injection": "enabled"'
