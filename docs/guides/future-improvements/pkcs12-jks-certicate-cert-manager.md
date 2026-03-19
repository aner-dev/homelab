- If you ever plan to run Java-based applications (like some monitoring tools or older enterprise FOSS) or if you want to export this cert easily, you can tell cert-manager to also generate a PKCS12 or JKS file inside the same Secret.
- see -> `infrastructure/controllers/cert-manager/base/certificate.yaml`
```yaml
  keystores:
    pkcs12:
      create: true
      passwordSecretRef:
        name: cert-pass-secret
        key: password
```
Note: For a standard Traefik/Go/Rust stack, you do not need this. It is just a "Senior" detail to keep in mind for future-proofing.
