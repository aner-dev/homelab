|**Configuration Block**|**Production Relevance**|**Senior Audit Question**|
|---|---|---|
|**`spec.config.oidc`**|Links Headscale to your **Kanidm** IAM engine for true Single Sign-On.|Are client scopes (`openid`, `profile`, `groups`) correctly declared to pass identities?|
|**`spec.config.dns`**|Configures **MagicDNS** so your nodes can reach each other using hostnames instead of raw tailscale IPs.|Is the `base_domain` parameter mapped out to match your homelab’s internal zone split?|
|**`spec.config.ip_prefixes`**|Dictates the exact internal IPv4 and IPv6 routing blocks allocated to your WireGuard overlay mesh.|Do these subnets intersect or collide with your existing K3s cluster pod/service CIDRs?|
|**`spec.config.derp`**|Controls Design Encrypted Relay Protocol servers to bypass strict NAT firewalls when direct connections fail.|Should you disable global STUN paths and pin localized relay endpoints for security?|
