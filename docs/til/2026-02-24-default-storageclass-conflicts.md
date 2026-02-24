# Issue: Metadata Ambiguity
In Kubernetes, having multiple `StorageClass` resources marked as `(default)` creates a metadata conflict. When a `PersistentVolumeClaim` (PVC) is submitted without an explicit `storageClassName`, the **Kubelet/Provisioner** encounters ambiguity. This results in non-deterministic volume provisioning or outright failure of the PVC to bind.

## Common Cloud/Production Scenarios
This conflict is frequent in professional environments during storage migrations or cluster bootstrapping:
* **Cloud Migrations:** Moving from a cloud provider's default (e.g., `gp2` on AWS) to a custom CSI (like `ebs-csi` or `Portworx`) without demoting the original.
* **Distribution Defaults:** Installing K3s or Rancher, which ships with `local-path` as the default, then deploying a production-grade engine like **Longhorn** or **Ceph/Rook**.
* **Bootstrap Logic:** Automated Terraform or Helm scripts that deploy storage drivers but fail to unset the pre-existing system defaults.

## Resolution
To ensure **Longhorn** is the primary "source of truth" for storage, the pre-existing provisioner must be demoted via a metadata patch.

### Demoting the Secondary Class
```bash
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
