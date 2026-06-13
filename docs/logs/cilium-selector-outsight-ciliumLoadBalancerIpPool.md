The cilium documentation explicitly states: "The pool will allocate to any service if no service selector is specified."

The Risk: If you have a "Production" pool and a "Testing" pool but forget the serviceSelector, a testing service might "steal" a production IP.

Rule: Always use `matchLabels` in `CiliumLoadBalancerIPPool` manifests.
