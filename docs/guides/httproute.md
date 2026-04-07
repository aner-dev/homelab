# supported cilium ingress annotations (gateway API xRoutes)
- all these cilium annotations belong to `kind: HTTPRoute` manifests.
ingress.cilium.io/loadbalancer-mode
ingressController.loadbalancerMode.
ingress.cilium.io/loadbalancer-class
ingress.cilium.io/service-type
ingress.cilium.io/service-external-traffic-policy
ingress.cilium.io/insecure-node-port
ingress.cilium.io/secure-node-port
ingress.cilium.io/host-listener-port
ingress.cilium.io/tls-passthrough
ingress.cilium.io/force-https
ingress.cilium.io/request-timeout
## cloud provider specific annotations for LoadBalancer services
lbipam.cilium.io
nodeipam.cilium.io
service.beta.kubernetes.io
service.kubernetes.io
cloud.google.com


