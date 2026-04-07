```yaml
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: ${CONTROLLER_NAME}-controller-policy
  namespace: ${CONTROLLER_NAMESPACE}
spec:
  endpointSelector:
    matchLabels:
      # Use the standard labels you already have in your HelmReleases
      app.kubernetes.io/instance: ${CONTROLLER_NAME} 
  egress:
    # 1. The "Management" Rule: Controllers MUST talk to the brain
    - toEntities:
        - kube-apiserver
    # 2. The "Internal" Rule: Allow talking to other pods in the same namespace
    - toEndpoints:
        - matchLabels:
            "k8s:io.kubernetes.pod.namespace": ${CONTROLLER_NAMESPACE}
  ingress:
    # 3. The "Observability" Rule: Allow Prometheus to scrape
    - fromEndpoints:
        - matchLabels:
            "k8s:io.kubernetes.pod.namespace": monitoring
      toPorts:
        - ports:
            - port: "${METRICS_PORT}"
              protocol: TCP
```
