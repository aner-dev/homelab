# ADR 001: Longhorn Storage Redirection via Bind Mount

**Date:** 2026-03-28  
**Status:** Accepted  

## 1. Context and Problem Statement

The host system runs **Artix Linux** on an encrypted LUKS/LVM setup with a non-uniform storage distribution:
* **Root Partition (`/`):** 118GB (Limited space, currently contains `/var/lib`).
* **Home Partition (`/home`):** 810GB (Primary storage capacity).

Longhorn and K3s default to storing data in `/var/lib/`, which resides on the small Root partition. Initial discovery using `dust` and `du` revealed that container build artifacts (Buildah/Podman) and logs frequently push the Root partition toward **83% exhaustion**, posing a critical stability risk to the host. 

We need a way to utilize the 810GB capacity of the `/home` partition for Kubernetes storage without breaking standard paths or creating "configuration drift" in our GitOps manifests.

## 2. Decision Drivers

* **Standardization:** Kubernetes manifests should stay "clean" using standard paths (`/var/lib/longhorn`).
* **Stability:** Prevent "Disk Pressure" evictions on the Root partition.
* **Maintainability:** Avoid mixing system-level infrastructure data with personal user files in `~/`.
* **Performance:** Ensure the filesystem is treated as a "First-Class Citizen" by the Longhorn CSI driver.

## 3. Considered Options

* **Option 1: Symlinks (`ln -s`):** Easy to implement but can be deleted accidentally and occasionally causes path resolution issues with container runtimes.
* **Option 2: Changing Helm Values:** Setting `defaultDataPath: /home/longhorn`. This works but results in non-standard configurations and places system data inside a user-focused partition.
* **Option 3: Kernel-level Bind Mount (Selected):** Mirroring a directory from `/home` to `/var/lib` at the kernel level via `/etc/fstab`.

## 4. Decision Outcome

We will implement a **Kernel-level Bind Mount**.

* **Physical Storage:** All "heavy" data will reside in a hidden system directory: `/home/.system/longhorn`.
* **Logical Mapping:** This directory is mirrored to the standard `/var/lib/longhorn` via `/etc/fstab`.
* **Mechanism:** The `bind` mount ensures that the OS and all applications treat the path as a native directory while physically writing to the larger partition.

### Implementation Details

#### Filesystem Setup
```bash
sudo mkdir -p /home/.system/longhorn
sudo mkdir -p /var/lib/longhorn
