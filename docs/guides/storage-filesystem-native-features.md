# Storage: Native File System Integration

## 1. Leveraged Features
Longhorn is designed to **leverage** (make use of) native Linux file system features rather than re-implementing them.

- **Sparse Files:** Used for thin provisioning.
- **Direct I/O:** Used for high-performance data paths.
- **Sync/Fsync:** Used to ensure data integrity on the physical NVMe.

## 2. Interaction Layer
1. **Application:** Writes to a `PersistentVolume`.
2. **Longhorn Engine:** Receives the write and sends it to the replica.
3. **Linux Kernel (Artix):** Receives the write from Longhorn and allocates a physical block in the sparse `volume.img` file.
4. **Hardware (NVMe):** Physically stores the electrons in the NAND cells.

## 3. Risks of Native Integration
Since Longhorn "makes use of" the host file system, if the host file system is corrupted (e.g., an unsafe shutdown of your Ryzen PC), the Longhorn replicas could also be affected. 
- **Mitigation:** Always use a UPS (Uninterruptible Power Supply) and follow the "Safe Reboot" procedures in our `node-maintenance.md` guide.
