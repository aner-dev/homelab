# Networking Signatures & The Arithmetic of Sessions

## 1. Rationale: From Magnitudes to Identity
Infrastructure in the Athanor cluster operates on a **Zero-Trust** model. Network interactions are treated as logical equations rather than simple connections.

* **The 5-Tuple as Magnitudes:** Every packet contains five specific parameters: Source IP, Destination IP, Source Port, Destination Port, and Protocol. These are the "magnitudes" of the network interaction.
* **The Resultant Object (The Session):** The combination of these five magnitudes creates a **Network Session**. This session is the resultant object that provides the **uniqueness** required for the OSI model to function. Without this 5-tuple combination, Layer 6 (Presentation) and Layer 7 (Application) would lack a distinct, identifiable foundation for communication.
* **Signatures as Abstractions:** A "Signature" is a logical abstraction derived from common patterns. Because specific services like DNS or Gateways possess specific "quantities" within their 5-tuple magnitudes, they constitute distinct entities. This arithmetic allows for the identification of traffic identity based on its 5-tuple fingerprint.

## 2. The 5-Tuple: The Essential Fingerprint
The 5-Tuple is the core paradigm for identifying network flows. It serves as the primary key for tracking sessions across the infrastructure.

| Element | Description | Athanor/Cilium Context |
| :--- | :--- | :--- |
| **Source IP** | The Initiating Entity | Mapped to **Pod Identity** labels. |
| **Dest IP** | The Receiving Entity | Mapped to **Service Identity** labels. |
| **Source Port** | The Outbound Door | Typically **Ephemeral** (dynamic assignment). |
| **Dest Port** | The Service Entry | The **Magnitude** defining the service (e.g., 53, 443). |
| **Protocol** | The Transport Method | Typically **TCP** (Reliable) or **UDP** (Fast/DNS). |

## 3. Standard Networking Signatures
The following signatures are the primary fingerprints used to define the `CiliumClusterwideNetworkPolicy` (CCNP).

| Service Type | Protocol | Dest Port (Magnitude) | Rationale |
| :--- | :--- | :--- | :--- |
| **DNS (Blocky)** | `UDP / TCP` | `53` | Core utility for name resolution. |
| **Web (Gateway)** | `TCP` | `80 / 443` | Inbound/Outbound traffic via Traefik. |
| **Database** | `TCP` | `5432` | Postgres SQL wire protocol. |
| **Observability** | `TCP` | `9090` | Prometheus metric scraping signature. |
| **Cache (Redis)** | `TCP` | `6379` | High-speed data transfer signature. |

## 4. Synthesis: Whitelist Logic & Policy Enforcement
By using **Identity-based Selectors**, the system performs pattern matching against these signatures:
1.  **Declaration:** A **Signature** is defined within the global policy (e.g., "Allow TCP 443").
2.  **Attachment:** Applications declare an **Attachment** to those rules via specific labels.
3.  **Enforcement:** The system enforces **Default Deny**. Unless a 5-tuple combination matches a defined signature, the resultant session object is never created, and traffic is dropped.

# improvements of the note 
## Terminology: "Signature" vs. Official Names
- The term "Signature" is widely used in the security industry, specifically regarding IDS/IPS (Intrusion Detection/Prevention Systems) and DPI (Deep Packet Inspection).
  - In those contexts, it is the official term for a pattern that identifies a specific application or threat.
- However, within **standard Kubernetes and Cilium documentation,** different terms are used to describe these "entities":

|**Level**|**Common Terminology**|**Official Cilium/K8s Term**|
|---|---|---|
|**L3/L4 (5-tuple)**|Traffic Profile / Flow|**Network Policy Rule**|
|**Identity**|Signature / Role|**Security Identity**|
|**L7 (App Layer)**|App Signature / Fingerprint|**Application-Aware Policy**|
## Conclusion
- Using "Signature" is an accurate analogy that professional engineers will understand, but in a formal audit, the term "Security Identity" or "Intent-based Rule" is more standard.
