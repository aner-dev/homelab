## [SEC-001] API Token Isolation (Passive Workloads)

**Status:** Adopted (Standard Practice)
**Date:** 2026-03-14

### Context
By default, Kubernetes mounts a ServiceAccount JWT token into every Pod. For passive applications (Linkding, CommaFeed, etc.), this token is an unnecessary **attack vector** that facilitates lateral movement if the container is compromised.

### Decision
All "Passive" workloads (apps not requiring communication with the Kubernetes API) must explicitly disable token mounting.

### Implementation
```yaml
spec:
  template:
    spec:
      automountServiceAccountToken: false
