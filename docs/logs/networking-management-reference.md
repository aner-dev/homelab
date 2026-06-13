|**Category**|**Tools**|**Where it fits in your homelab**|**Why you (or a Senior) would use it**|
|---|---|---|---|
|**Mesh VPN**|**Tailscale**, **Headscale**, **EasyTier**|Outside the cluster.|To access your Artix PC from a coffee shop without opening ports.|
|**Tunnel / Reverse Proxy**|**frp**, **rathole**|At the edge.|To expose your Traefik Gateway to the internet if you are behind a NAT/CGNAT.|
|**Cloud VPN**|**Algo**|Remote Infrastructure.|To set up a private, secure gateway in a VPS (not for your local homelab).|
|**Internal Encryption**|**Cilium WireGuard**|Inside the cluster.|To encrypt traffic _between_ your pods automatically at the kernel level.|
|**Identity / mTLS**|**Cilium + SPIRE**|Inside the cluster.|To prove _which_ pod is talking to which pod (Zero Trust).|
|**L7 Traffic Management**|**Cilium-Envoy**|Inside the cluster.|To do "Smart" routing (e.g., retrying a failed HTTP request or path-based routing).|
