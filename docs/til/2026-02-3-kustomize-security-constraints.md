# TIL: Kustomize Root Restrictions & Resource Linking
## 🚫 The Constraint: "No Parent References"
Kustomize does not allow a kustomization.yaml to reference files located in a parent directory or a sibling directory using relative paths like ../base/file.yaml.

## Why does this exist? Principles
- Hermetic Builds (Reproducibility)
  - Kustomize wants the "Build Context" to be self-contained. If you could pull files from anywhere on your hard drive, your GitOps pipeline might fail because it doesn't have the same folder structure as your laptop.

- Security (The Jail)
  - It prevents a user from accidentally (or maliciously) including sensitive files from outside the project scope (like ../../.ssh/id_rsa).

- Portability
  - By forcing you to treat directories as "packages," the code becomes modular.

## Solution: Directory Referencing
Instead of pointing to specific files in a distant folder, you point to the directory itself.

Wrong:
```yaml
resources:
  - ../base/helmrepo.yaml # Fails: Outside of root
```
Right:
```yaml
resources:
  - ../base # Success: Treats the folder as a modular dependency
```
## Implementation Rule
- Local Files: Use file names for resources in the same directory.

- Remote/External Resources: Use directory paths (local) or URLs (remote git repos) to include blocks of logic.
