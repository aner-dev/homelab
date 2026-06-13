# conventions
## `metadata.name`
- allow-internal/external-gateway
- example:
```yaml 
# ./apps/linkding/base/reference-grant.yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-internal-gateway
  namespace: linkding
```
