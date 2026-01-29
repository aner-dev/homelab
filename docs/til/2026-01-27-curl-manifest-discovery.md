# 27th Janurary
I wasn't sure about how actually test & discover .yaml files of resources
specifically rustfs k8s deployment 
and I encounter this 'command pattern' or 'template' very useful:
`curl -L <URL> > [filename].yaml`
and I also create a `tests/` directory for testing and discovery interactions like this
# 28th Janurary
Today again, inspect a *YAML manifest* with `curl` allows me to customize my homelab infrastructure. 
```yaml
resources:
  - https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
```
that resource has `reclaimPolicy: Delete`
Without inspecting with curl, I will have an storage issue in the future, because that policy doesn't integrates well with my current infrastructure approaches.
Also I learn that the `patches:` block of kustomization.yaml allows me to customize, if my redundancy is excused, that YAML manifest without changing it directly.
Maintain it 'clean and pure', and only putting on them my specific customization. 

# TIL: Inspecting Remote Manifests via Curl

## 💡 The Spark
I wasn't sure how to verify the content of a remote YAML before applying it to the cluster.

## 🛠️ The Discovery
Instead of blindly applying a URL, I can pipe it to a file or stdout:
`curl -L <URL> > manifest.yaml`

## 🧠 Key Insight
Rancher's `local-path-provisioner` has a default `reclaimPolicy: Delete`. 
**Warning:** This is dangerous for my homelab if I expect data persistence.

## 🚀 Action Item
Always check the `reclaimPolicy` in remote manifests and use **Kustomize Patches** to override them instead of modifying the downloaded file.
