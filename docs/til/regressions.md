# 🔍 What is a Regression?
A regression is a software bug that causes a previously working feature to stop functioning after an update. In this case:

The Event: `Error: unknown shorthand flag: 'c' in -c.` at executing `kustomize build --enable-helm infrastructure/controllers/external-secrets/base`

The Cause: kustomize v5.8.0 attempted to call helm version -c, a legacy flag removed in helm v4+.

The Finding: The "latest" version of Kustomize (v5.8.0) was explicitly flagged by maintainers for a **regression** in namespace propagation.

# Project Decisions and Improvements
Version Pinning (Mise): Do not rely on "system" binaries. 
Use .mise.toml to ensure every environment (Local, CI/CD, Production) uses identical, tested versions.

## approaches
- Avoid "bleeding edge" versions (e.g., Helm 4) immediately upon release.
- Standardize on LTS (Long Term Support) versions (e.g., Helm 3.16) until the ecosystem catches up.

- Read the Release Notes: 
  - Always check the "Fixes" and "Regressions" sections of a GitHub release before upgrading core infrastructure controllers.
