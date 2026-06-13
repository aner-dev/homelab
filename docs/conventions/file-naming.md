# Infrastructure Naming Conventions

This document outlines the standard naming patterns for the `homelab` repository to ensure consistency across GitOps reconciliations.

## 1. File Naming (Kebab-Case)

All Kubernetes manifest filenames must strictly follow the **Kind-to-Kebab** mapping. This aligns the filename with the `kind` field inside the YAML.

| Kubernetes Kind | Filename Convention |
| :--- | :--- |
| `HelmRepository` | `helm-repository.yaml` |
| `HelmRelease` | `helm-release.yaml` |
| `Kustomization` | `kustomization.yaml` |
| `Namespace` | `namespace.yaml` |
| `ConfigMap` | `config-map.yaml` |

### Why?
- **Global Search:** Searching `helm-release` in Neovim results in clean, relevant matches.
- **Predictability:** No guessing if a file is named `helmrelease`, `hr.yaml`, or `release.yaml`.
- **API Alignment:** Matches the FluxCD and Kubernetes API resource names.

## 2. Directory Structure

Sources (Repositories) and Controllers (Releases) are separated to allow one-to-many mapping.

- `infrastructure/sources/`: Contains all `helm-repository.yaml` files.
- `infrastructure/controllers/<app>/`: Contains the `helm-release.yaml` and logic for specific deployments.
