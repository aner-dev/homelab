**The Scraper is the client (VictoriaMetrics), while the Node Exporter is the Server (the target).**

The `node-exporter` is a **Metric Translator**.

1. It reads raw, unformatted data from the Linux Kernel (via `/proc` and `/sys`).
    
2. It translates that data into the **Prometheus Exposition Format** (the "Metrics Dialect").
    
3. It serves that data over HTTP on port `9100`.
# Core Concepts & Documentation
- 4 pillars:

- **`/proc` and `/sys` filesystems:** Node-exporter is essentially a "web wrapper" for these directories.
    
- **DaemonSets & "node-scope":** Unlike a Deployment (which runs anywhere), a DaemonSet ensures exactly **one pod per node**.
    
- **Host-Level Namespaces:** Understanding `hostNetwork`, `hostPID`, and `hostIPC` is critical.
  - These fields "break" the container isolation so the binary can see your actual hardware.
    
- **The VictoriaMetrics CRD Dialect:** * **VMNodeScrape:** This is the specific CRD to use for Node Exporter.
- **Why?:** It follows the same "label-selector" logic as `VMServicescrape`, but it is specialized for discovering **Nodes** rather than **Services**.
# collectors 
- It is a small code module inside the binary dedicated to one specific Linux subsystem.

- **Default Collectors:** These are the ones everyone needs (CPU, Memory, Disk).
- **Disabled Collectors:** These are "Specialty" metrics.
  - They are off by default because they are either "heavy" (use too much CPU) or "niche" (most people don't need them).
## coding `HelmRelease`
- the collectors flags and granular configurations for them are applied in `spec.values.extraArgs:`
- example code:
```yaml 
spec:
  values:
    extraArgs:
      # Enable a disabled collector
      - --collector.systemd 
      # Disable an annoying default collector (e.g., if you don't have InfiniBand)
      - --no-collector.infiniband
      # Filter what the filesystem collector looks at (Senior Habit: Reduce Noise)
      - --collector.filesystem.mount-points-exclude=^/(dev|proc|sys|var/lib/docker/.+)($|/)
```
