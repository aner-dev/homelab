# comparison with alternatives
|**Feature**|**Istio**|**Linkerd**|**Cilium Service Mesh**|
|---|---|---|---|
|**Architecture**|Sidecars (Envoy in every Pod)|Sidecars (Rust-based)|**Sidecarless (eBPF + Envoy)**|
|**Resource Cost**|High (Heavy RAM usage)|Low (Fast/Light)|**Very Low** (Shared Envoy)|
|**Philosophy**|"Feature for everything"|"Simplicity & Security"|**"Kernel-level Performance"**|
|**Integration**|Separate from Network|Separate from Network|**Unified with CNI**|
# Why Cilium is the choosed option for Athanor

- Reduced Footprint: Since you are on a single node, you don't want to waste 2GB of RAM on 50 Istio sidecars. Cilium runs one Envoy proxy per node, saving huge amounts of memory.

- Unified Logic: You manage your L3/L4 (Firewall) and your L7 (Service Mesh) in the same place.

- Modern standard: eBPF is currently "surfacing" as the future of the industry. Mastering Cilium Service Mesh puts you ahead of engineers who only know "old school" Istio.

# improvements
- **mTLS:**
  - Automatic "handshakes" between pods so traffic is encrypted.
- **L7 Traffic Management:**
  - You can do "Canary deployments" (send 10% of traffic to a new version of Forgejo).
- **Observability:**
  - Using Hubble, you can see the actual HTTP paths and status codes ($200$, $404$, $500$) moving between your pods.
