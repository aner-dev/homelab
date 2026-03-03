# Hardening Standard for Public-Facing Applications

## Status: Mandatory for Ingress-Enabled Pods
**Goal:** Minimize the "Blast Radius" and prevent "Lateral Movement" if the application layer is compromised.

---

## Layer 1: Read-Only Filesystem (Immutable Runtime)
**Concept:** Prevents an attacker from downloading tools (shells, scripts, miners) into the pod.
* **Mechanism:** Mount the root filesystem as read-only. Use `emptyDir` volumes only for specific temporary paths if required.
* **Implementation:**
  ```yaml
  securityContext:
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    runAsUser: 1000
## Layer 2: Network Isolation (Micro-segmentation)
- Concept: Blocks the "Hacker Scope" to the local pod.
 
- Mechanism: Use a NetworkPolicy to deny all internal (East-West) traffic.
 
- Rule: * Allow: Inbound from Traefik (Ingress).
 
- Allow: Outbound to Internet (Egress - optional).
 
- Deny: All traffic to other namespaces (OpenBao, Blocky, etc.).

## Layer 3: ServiceAccount Neutering (Identity Lockdown)
- Concept: Removes the pod's ability to "talk" to the Kubernetes API.
 
- Mechanism: Assign a dedicated ServiceAccount with zero RBAC roles and disable token automounting.

- Implementation:
```yaml
spec:
  serviceAccountName: website-unprivileged-sa
  automountServiceAccountToken: false
```
## Layer 4: Distroless/Minimal Images (Binary-Only)
- Concept: Removes the "Hacker Toolkit" from the container.
 
- Mechanism: Use images that do not contain sh, bash, curl, or apt.
 
- Standard: gcr.io/distroless/static or multi-stage builds that result in a single binary/static file.
 
- Outcome: Even with a shell exploit, the attacker has no binaries to execute.

# Summary of the "Powerless" Hacker
- By applying these, the hacker's "scope" is limited to:
 
- Defacing the website (changing the HTML).
 
- Stealing whatever data the website already shows to everyone else.
 
- They cannot steal OpenBao secrets, they cannot see my other apps, and they cannot control my Linux server.
