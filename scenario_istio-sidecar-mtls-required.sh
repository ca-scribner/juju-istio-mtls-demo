# * istio deployed
# 	* no communication restrictions set up (mTLS is not required, and no AuthorizationPolicy defaults are set, so everything should be able to talk to everything)
# * All pods in all namespaces mutated to have label istio-injection=enabled (via kyverno/mutating webhook), so all resources in all namespaces get istio sidecars automatically
# * bootstrap juju

# Prereq: have an existing cluster (install microk8s, `kind create cluster --name test-istio-juju`, etc)
K8S_CLUSTER="kind-test-istio-mtls"

./add-istio.sh
./add-kiali.sh
./istio-require-mtls.sh
./add-kyverno.sh

# bootstrap juju
juju bootstrap $K8S_CLUSTER $K8S_CLUSTER --no-gui
# Result:
# Creating Juju controller "kind-test-istio-mtls" on kind-test-istio-mtls
# Bootstrap to generic Kubernetes cluster
# Juju Dashboard installation has been disabled
# Creating k8s resources for controller "controller-kind-test-istio-mtls"
# Downloading images
# Starting controller pod
# Bootstrap agent now started
# Contacting Juju controller at 10.96.192.171 to verify accessibility...
# ERROR lost connection to pod
# ERROR lost connection to pod
# ERROR lost connection to pod
# ...
# I think the controller does come successfully, but then other things aren't working? 
