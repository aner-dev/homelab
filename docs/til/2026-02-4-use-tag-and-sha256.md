📝 TIL: Container Image Pinning (Tags vs. Digests)
🔍 Context
While deploying AdGuard Home in my homelab, I researched the most secure way to reference container images in Kubernetes deployment.yaml.

# Discovery & Improvements
There are 3 levels of "pinning" an image:
1. The Floating Tag (Bad): adguardhome:latest or adguardhome:v0.107.
2. Risk: The image can change under your feet without a version bump.
3. The Semantic Tag (Good): adguardhome:v0.107.52.

- Implementation: include [tag]+[sha256] in the `image:` yaml field 
  - `Tag` for readability and the `Digest` for immutability:
- Benefits:
  - Readability, Immutability and Stability.
  - Mathematically guaranteed to never change.

```yaml
image: adguard/adguardhome:v0.107.52@sha256:9d0282c10673117d6ae2312ad48379a259b7bdb3e4931470a4b383c839a3eabf
```
# related: 'Zombie Provider' Issue
Using only tags can lead to Image Drift Zombies
Where different nodes in the same cluster run different versions of the same "tagged" image because they pulled them at different times. Pinning by SHA256 kills this issue entirely.
