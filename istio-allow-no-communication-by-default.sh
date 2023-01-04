### Allow no communication by default
# This sets the default allow rules of the istio sidecar to allow nothing
# Effect of this is that no sidecars can talk to other sidecars by default
# and instead we must create AuthorizationPolicy objects to allow specific communication
# Again, by applying to namespace: istio-system this becomes the default
kubectl create -f allow-nothing-authorizationpolicy.yaml -n istio-system
