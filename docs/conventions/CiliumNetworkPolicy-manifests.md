## Manifest Naming Conventions

To maintain high observability and rapid navigation within the `athanor` cluster (especially when using Neovim/Telescope/Television), we follow a strict naming pattern for networking resources.

| Target | Why it is relevant | Senior Audit Question |
| :--- | :--- | :--- |
| **`<app>-cnp.yaml`** | **CiliumNetworkPolicy**: Ensures unique buffer names in Neovim and high-accuracy fuzzy finding. | If I have 10 tabs open, can I instantly distinguish the Linkding policy from the Forgejo policy? |
| **`<app>-ccnp.yaml`** | **CiliumClusterwideNetworkPolicy**: Explicitly marks global-scope rules that affect the whole cluster. | Is this policy truly global, or should it be restricted to a specific namespace? |
| **`httproute.yaml`** | **Gateway API**: Standardized routing manifest. Usually 1-per-app, so specific prefixing is optional but recommended if multiple routes exist. | Does this route align with the `athanor.io/gateway-zone` labels? |

### Neovim Workflow Tip
By using `<app>-cnp.yaml`, you can jump to a policy from anywhere in your terminal or editor using:
- **CLI**: `tv -e yaml cnp` (Using Television)
- **LazyVim**: `<leader>ff` (Telescope) then type `link cnp`.
