### Require mTLS
# Force all istio sidecars to only allow mTLS communication (eg: will talk to other sidecars, but not talk to anything off service mesh)
# This applies globally because we set it in namespace: istio-system
kubectl create -f strict-tls-peerauthentication.yaml -n istio-system
# This would apply just to namespace: foo
# kubectl create -f strict-tls-peerauthentication.yaml -n foo
