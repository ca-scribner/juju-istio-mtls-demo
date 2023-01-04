# * bootstrap juju first
# * istio deployed
# 	* no communication restrictions set up (mTLS is not required, and no AuthorizationPolicy defaults are set, so everything should be able to talk to everything)
# * All pods in all namespaces mutated to have label istio-injection=enabled (via kyverno/mutating webhook), so all resources in all namespaces get istio sidecars automatically
# * deploy charms

# Prereq: have an existing cluster (install microk8s, `kind create cluster --name test-istio-juju`, etc)
K8S_CLUSTER="kind-test-istio-mtls"

# bootstrap juju
juju bootstrap $K8S_CLUSTER $K8S_CLUSTER --no-gui
# Result: ok!

./add-istio.sh
./add-kiali.sh
./add-kyverno.sh

# Add this after kyverno is set up, so that this namespace gets the istio-injection=enabled label
juju add-model istio-test

juju deploy minio --channel latest/edge
# Result: Active/Idle

juju deploy prometheus-k8s --channel=1.0/stable --trust
# Result: Active/Idle
