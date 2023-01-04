# Testing of Juju in different istio environments

This repo has several test cases ("scenario-\*") which simulate different environments that we might bootstrap Juju into.  Description of the cases and results are (see the .sh files themselves for more details):

* scenario_istio-sidecar-no-communication-restrictions.sh
	* bootstrapping juju into an environment that injects istio sidecars but has no communication restrictions
	* result: bootstrap gets stuck
* scenario_istio-sidecar-mtls-required.sh
	* bootstrapping juju into an environment that injects istio sidecars and tells the istio service mesh to reject anything that is not mTLS (eg: only talk to other things on the mesh)
	* result: bootstrap gets stuck
* scenario_bootstrap-juju-before-istio.sh
	* bootstrap juju before turning on istio sidecar injection (thus juju controlled does not get an istio sidecar)
	* after bootstrapped, deploy istio etc and enforce no communication restrictions 
	* deploy some charms
	* result: seems to work
* scenario_bootstrap-juju-before-istio_require-mtls.sh
	* bootstrap juju before turning on istio sidecar injection (thus juju controlled does not get an istio sidecar)
	* after bootstrapped, deploy istio etc and enforce mTLS requirements
	* deploy some charms
	* result: seems to work <--this is surprising to me
* scenario_bootstrap-juju-before-istio_require-mtls-and-deny-traffic.sh
	* bootstrap juju before turning on istio sidecar injection (thus juju controlled does not get an istio sidecar)
	* after bootstrapped, deploy istio etc and enforce mTLS requirements and tell sidecars to reject all communication unless it is specifically authorized in an AuthorizationPolicy
	* deploy some charms
	* result: seems to work <--this is surprising to me
