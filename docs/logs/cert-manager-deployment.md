# Desec.io ClusterIssuer
```yaml
    solvers:
      - selector:
        dnsNames:
          - "*.yourdomain.com"
          - "yourdomain.com"
```
- Declaring the subdomain inside the global `ClusterIssuer `configuration creates a redundant, tight coupling that completely breaks the DRY (Don't Repeat Yourself) pattern.
  - It forces me to maintain an identical domain string across 2 completely separate abstraction layers, doubling the configuration management overhead for zero security or operational gain.
