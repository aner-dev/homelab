|**Persona**|**Primary Resource**|**Responsibility**|
|---|---|---|
|**Infrastructure Provider**|`GatewayClass`|Installs the controller (Traefik) and defines the "flavor" of the load balancer.|
|**Cluster Operator (You)**|`Gateway`, `Namespace`, `CCNP`|Defines **who** is allowed to talk to **what**. You own the "Fences" (Labels on Namespaces).|
|**Application Developer**|`HTTPRoute`, `CNP`|Defines **how** the app is exposed (Paths, Retries, Services). They do **not** touch the Gateway or Namespace labels.|

