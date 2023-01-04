echo "Script running with MODEL_NAMESPACE=$MODEL_NAMESPACE"

kubectl create ns controlled-ns-1
kubectl apply -f istio-1.16.1/samples/httpbin/httpbin.yaml -n controlled-ns-1
kubectl apply -f istio-1.16.1/samples/sleep/sleep.yaml -n controlled-ns-1

kubectl create ns controlled-ns-2
kubectl apply -f istio-1.16.1/samples/httpbin/httpbin.yaml -n controlled-ns-2
kubectl apply -f istio-1.16.1/samples/sleep/sleep.yaml -n controlled-ns-2

kubectl create -f uncontrolled-ns-1-no-kyverno.yaml
kubectl apply -f istio-1.16.1/samples/httpbin/httpbin.yaml -n uncontrolled-ns-1
kubectl apply -f istio-1.16.1/samples/sleep/sleep.yaml -n uncontrolled-ns-1

# Add to a model

kubectl apply -f istio-1.16.1/samples/httpbin/httpbin.yaml -n $MODEL_NAMESPACE
kubectl apply -f istio-1.16.1/samples/sleep/sleep.yaml -n $MODEL_NAMESPACE

kubectl rollout status deployment -n $MODEL_NAMESPACE sleep --timeout=90s
kubectl rollout status deployment -n $MODEL_NAMESPACE httpbin --timeout=90s

# Avoid race conditions
sleep 5

# Run tests
echo
echo "Running connection tests where a pod called 'sleep' tries to contact a pod called httpbin between different controlled (istio enabled) and uncontrolled namespaces"
echo "Legend for responses:"
echo "* 200: communication successful"
echo "* 403: communication blocked by an AuthorizationPolicy"
echo "* 000 + another line saying exited with code 56: blocked because mTLS is required and one side does not have an istio sidecar"
echo
for from in "controlled-ns-1" "controlled-ns-2" "uncontrolled-ns-1" "$MODEL_NAMESPACE"; do for to in "controlled-ns-1" "controlled-ns-2" "$MODEL_NAMESPACE" ; do kubectl exec "$(kubectl get pod -l app=sleep -n ${from} -o jsonpath={.items..metadata.name})" -c sleep -n ${from} -- curl http://httpbin.${to}:8000/ip -s -o /dev/null -w "sleep.${from} to httpbin.${to}: %{http_code}\n"; done; done