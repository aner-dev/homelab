# Why `replace()`?
- In the `assume_role_policy`, you see `${replace(aws_iam_oidc_provider.athanor.url, "https://", "")}`.

Senior Tip: AWS IAM expects the OIDC condition key without the https:// prefix. Using replace() ensures that if you ever change your domain, Tofu handles the formatting logic automatically, preventing a 403 Access Denied error that is very hard to debug.
# serviceAccount manifest example 
```yaml 
# Example: The "Link" in your K8s manifest
apiVersion: v1
kind: ServiceAccount
metadata:
  name: forgejo-sa
  annotations:
    # This is how the pod "points" to the cloud role
    eks.amazonaws.com/role-arn: arn:aws:iam::1234567890:role/athanor-forgejo-s3-role
```
# Short-Lived, Identity-Based Access
- temporary credentials with highly restricted permissions attached to a ServiceAccount k8s resource of a given application pod.

