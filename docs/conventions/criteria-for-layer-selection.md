# question: put `postgres/` in `infrastructure/configs` or in `infrastructure/applications`??
I will distinguish between Volatiles (Apps) and Statefuls (Databases).

Lifecycle Mismatch: You might update your linkding app five times a day. You might update your Postgres version once every six months. Keeping them in the same layer creates unnecessary risk for your data during app deployments.

Dependency Hierarchy: Multiple apps might eventually need to talk to the same Postgres instance (Shared Service). If Postgres is tucked inside the linkding/ folder, it’s logically "owned" by Linkding, making it awkward for other apps to use.

Backup & Recovery: By grouping Postgres, OpenBao, and Longhorn in the 03 layer, you can apply specific Flux postBuild substitutions or backup policies to that entire layer, ensuring your "Data Crown Jewels" are protected separately from your "Web Frontends."
