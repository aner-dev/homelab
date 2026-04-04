| Resource | Layer | Routing Identifier | Common Use Case | Why you need it over a simple Service |
| :--- | :--- | :--- | :--- | :--- |
| **`HTTPRoute`** | L7 | Hostname, Path, Headers | Web Apps (Grafana, Forgejo) | Allows "Canary" rollouts (send 10% traffic to v2) and path-based routing. |
| **`GRPCRoute`** | L7 | Service/Method names | Microservices communication | Optimized for the binary gRPC protocol; understands "Methods" instead of just "Paths". |
| **`TLSRoute`** | L4+ | SNI (Server Name Indication) | **Secure Databases (Postgres), Kafka** | **"TLS Passthrough"**: The Gateway sees the domain name but CANNOT read the data. The backend handles decryption. |
| **`TCPRoute`** | L4 | Port Number | **SSH, Non-TLS Databases** | When you have a raw stream of data that isn't web-based and doesn't have a hostname. |
| **`UDPRoute`** | L4 | Port Number | **DNS (Blocky), VoIP, Gaming** | High-performance, connectionless traffic where speed matters more than order. |
