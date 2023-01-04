# Installs istio with sidecar injection enabled

# Get istio
ISTIO_VERSION="1.16.1"
curl -L https://istio.io/downloadIstio | ISTIO_VERSION="$ISTIO_VERSION" sh -

ISTIOCTL="./istio-$ISTIO_VERSION/bin/istioctl"

# Deploy istio with auto sidecar injection (if namespace has label of 'istio-injection=enabled')
"$ISTIOCTL" install -y --set profile=default

# Wait just in case it isn't ready.  I think istioctl does this automatically
kubectl rollout status deployment -n istio-system istiod --timeout=90s