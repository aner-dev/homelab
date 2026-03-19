## TCP 
- example cases when to enable a TCP protocol on the `kind: Gateway` of **traefik**:
```yaml 

```
### 1. Databases (Remote Access)

If you run a database like **PostgreSQL**, **MySQL**, or **Redis** inside your cluster, and you want to connect to it using a tool on your laptop (like DBeaver or TablePlus) without using `kubectl port-forward`.

- **Protocol:** TCP
    
- **Common Port:** 5432 (Postgres), 3306 (MySQL), 6379 (Redis).
    
- **Why:** Databases don't use HTTP; they use their own binary protocols over TCP.
    

### 2. Gaming Servers

If you are hosting a **Minecraft**, **Rust**, or **Valheim** server for your friends.

- **Protocol:** TCP (and often UDP).
    
- **Common Port:** 25565 (Minecraft).
    
- **Why:** Game clients communicate with the server using custom packets that Traefik cannot "read" as a website.
    

### 3. Secure Shell (SSH)

If you want to SSH directly into a specific Pod or a "Jumpstack" inside your cluster from the outside world.

- **Protocol:** TCP
    
- **Common Port:** 22
    
- **Why:** SSH is a pure TCP protocol.
    

### 4. IoT and Messaging (MQTT)

If you have smart home devices (sensors, lights) talking to an **Mosquitto (MQTT)** broker in your homelab.

- **Protocol:** TCP
    
- **Common Port:** 1883 or 8883 (encrypted).
    
- **Why:** MQTT is a lightweight messaging protocol for "Machine-to-Machine" communication.

