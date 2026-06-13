# hostPath
|**Component**|**Why it needs hostPath**|
|---|---|
|**Cilium (CNI)**|To store BPF maps, manage the state of the network, and access the kernel's `/sys/fs/bpf`.|
|**Prometheus / VM (Observability)**|To read system logs from `/var/log` or hardware metrics from `/proc` and `/sys`.|
|**Longhorn (CSI)**|**Crucial:** Longhorn itself uses `hostPath` to store the actual data blocks on your NVMe drive (usually in `/var/lib/longhorn`).|
|**K3s / Containerd**|To access the container sockets in `/run/k3s/containerd/containerd.sock`.|
## security concerns about using HostPath 
- Because hostPath allows a Pod to "break out" of its container and touch your Artix Linux filesystem, it is a high-security risk.

- Bad Habit: Using hostPath for app data because it's "easier" than configuring a PVC.

- Good Practice: Restricting hostPath only to the kube-system namespace.
  - In a "Zero Trust" model, use Pod Security Admissions to prevent an <app> (Linkding e.g.) pod from ever being able to use a hostPath volume.
