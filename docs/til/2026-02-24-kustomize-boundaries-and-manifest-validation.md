# TIL: Kustomize Build-Time Directives vs. Kubernetes API Objects

## 1. The Distinction of the `configMapGenerator`
**Observation:** `configMapGenerator` is not a field recognized by the Kubernetes API.

**Technical Reality:**
`configMapGenerator` is a **Kustomize-specific directive**. It exists only during the "Build" or "Rendering" phase of your pipeline. When `kubectl kustomize` (or `k apply -k`) is executed, Kustomize intercepts this directive and **synthesizes** a standard Kubernetes `Kind: ConfigMap` manifest on the fly.

| Feature | `configMapGenerator` | `Kind: ConfigMap` |
| :--- | :--- | :--- |
| **Origin** | Kustomize Directive | Kubernetes API Object |
| **Lifecycle** | Build-time (Ephemeral) | Run-time (Persistent in etcd) |
| **Primary Value** | Automatic Hashing & Rolling Updates | Static Configuration storage |

**Fundamental Relation (Linux):**
This is analogous to a **Compiler Directive** in C or a **Macro**. The instruction tells the "compiler" (Kustomize) how to build the final binary (the final YAML stream) before it is sent to the "CPU" (the Kubernetes API server).



---

## 2. Strict Validation in the `resources:` Block
**Observation:** The `resources:` block in a `kustomization.yaml` is not a general file importer.

**Technical Reality:**
The `resources:` block acts as a **Manifest Loader**. It requires every file listed to be a "well-formed" Kubernetes object. This means the file must contain the mandatory headers:
* `apiVersion`
* `kind`
* `metadata`

### **Why raw files (like `config.yaml`) fail:**
A raw configuration file is just text/data. It lacks the "Identity" headers required by the Kubernetes API.
If Kustomize allowed raw files in the `resources` block, it would be sending "unstructured noise" to the API server, which would be immediately rejected by the **API Schema Validator**.

#### **Related (Kubernetes):**
This relates to the **Declarative Model**. Kubernetes expects every instruction to describe a specific **Resource State**. A raw text file does not describe a state; it provides data for a state.
