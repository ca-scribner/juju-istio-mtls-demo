# * bootstrap juju first
# * istio deployed
# 	* add a PeerAuthentication that strictly requires only mTLS communication on the service mesh (eg: doesn't let something off-mesh communicate with something on-mesh)
#   * add an AuthorizationPolicy that, by default, denies all traffic to all sidecars (allowed traffic requires an AuthorizationPolicy defining the traffic)
# * All pods in all namespaces mutated to have label istio-injection=enabled (via kyverno/mutating webhook), so all resources in all namespaces get istio sidecars automatically
# * deploy charms

# Prereq: have an existing cluster (install microk8s, `kind create cluster --name test-istio-juju`, etc)
K8S_CLUSTER="kind-test-istio-mtls"

# bootstrap juju
juju bootstrap $K8S_CLUSTER $K8S_CLUSTER --no-gui
# Result: ok!

./add-istio.sh
./istio-require-mtls.sh
./istio-allow-no-communication-by-default.sh
./add-kiali.sh
./add-kyverno.sh

# Add this after kyverno is set up, so that this namespace gets the istio-injection=enabled label
# used kubeflow name because some of the charms below need to be in model=kubeflow
MODEL_NAMESPACE=kubeflow
juju add-model "$MODEL_NAMESPACE"

juju deploy minio --channel latest/edge
# Result: Active/Idle

juju deploy prometheus-k8s --channel=1.0/stable --trust
# Result: Active/Idle

# juju ssh minio/0
# Result:  works

# juju config minio access-key=minio1
# Result:  works

juju deploy kubeflow-dashboard --channel 1.6/stable
juju deploy kubeflow-profiles --channel 1.6/stable --trust                
juju deploy admission-webhook --channel 1.6/stable --trust
juju relate kubeflow-dashboard kubeflow-profiles
# Result: Active/Idle, and I think working properly

# Run a generic "what can talk to what" test between namespaces
MODEL_NAMESPACE="$MODEL_NAMESPACE" ./test-istio-isolation.sh
# This should confirm that basically everything is locked down (403's and error 56's)