# * bootstrap juju first
# * istio deployed
# 	* add a PeerAuthentication that strictly requires only mTLS communication on the service mesh (eg: doesn't let something off-mesh communicate with something on-mesh)
# * All pods in all namespaces mutated to have label istio-injection=enabled (via kyverno/mutating webhook), so all resources in all namespaces get istio sidecars automatically
# * deploy charms

# Prereq: have an existing cluster (install microk8s, `kind create cluster --name test-istio-juju`, etc)
K8S_CLUSTER="kind-test-istio-mtls"

# bootstrap juju
juju bootstrap $K8S_CLUSTER $K8S_CLUSTER --no-gui
# Result: ok!

./add-istio.sh
./istio-require-mtls.sh
./add-kiali.sh
./add-kyverno.sh

# Add this after kyverno is set up, so that this namespace gets the istio-injection=enabled label
juju add-model istio-test

juju deploy minio --channel latest/edge
# Result: Active/Idle

juju deploy prometheus-k8s --channel=1.0/stable --trust
# Result: Active/Idle

# juju ssh minio/0
# Result: works

# juju config minio access-key=minio1
# Result: works

juju deploy kubeflow-dashboard --channel 1.6/stable
juju deploy kubeflow-profiles --channel 1.6/stable --trust                
juju deploy admission-webhook --channel 1.6/stable --trust
juju relate kubeflow-dashboard kubeflow-profiles
# Result: Active/Idle

# Run a generic "what can talk to what" test between namespaces
MODEL_NAMESPACE="$MODEL_NAMESPACE" ./test-istio-isolation.sh

# Not sure what else to test.  I expected to find things not working, but I guess everything (model operator and charm operators) are on the service mesh?  Is there anything that needs to communicate from outside the model into here?  If so, that might be broken.