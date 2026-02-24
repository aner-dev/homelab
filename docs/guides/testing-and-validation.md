# Homelab Testing & Validation Playbook

## Overview
This document tracks the evolution of testing methodologies within the cluster. The goal is to move from manual verification towards automated "Smoke Tests" that validate the core infrastructure (Storage, Networking, and Compute).

# testing tracking 

## Storage Smoke Testing (Longhorn)

### The Objective
To verify that the Container Storage Interface (CSI) can successfully provision, attach, and mount block devices to a workload on a non-systemd (Artix) host.

### The Test Manifest (`tests/storage/longhorn-smoke-test.yaml`)
I utilize a "Pod + PVC" combination to test the full lifecycle of a volume:
1. **PVC Creation:** Triggers the Longhorn Provisioner.
2. **Pod Scheduling:** Triggers the Longhorn Attacher.
3. **Mounting:** Triggers the Longhorn CSI plugin to handle mount propagation.
4. **I/O Operation:** A shell loop writes timestamps to ensure the Data Plane is writable.

### Validation Commands
```bash
# 1. Verify Binding
kubectl get pvc smoke-test-pvc -n default

# 2. Verify I/O (The "Timestamp" Check)
kubectl exec storage-checker -n default -- cat /mnt/data/test.log
