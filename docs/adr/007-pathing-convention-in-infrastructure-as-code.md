---
title: "Refactoring OpenBao: From God-Roles to Identity-Based PoLP"
date: 2026-02-19
tags:
  - kubernetes
  - security
  - openbao
  - tofu
description: "How I implemented a Secret Factory logic for a multi-app homelab."
---
ADR 007: Standardized Pathing and Identity Convention for IaC
Status
Accepted (2026-02-19)

Context
As I add more applications to the homelab, manually writing OpenBao (Vault) policies and roles for every new service is becoming repetitive and prone to errors. Previously, I named resources inconsistently (e.g., vault_policy.blocky), which made it impossible to predict the configuration for new environments like staging. I need a system where the directory structure, the secret paths, and the Kubernetes identities follow a single, predictable rule.

Decision
I am moving to a loop-based configuration where a single list of applications generates all necessary security resources. This relies on a strict naming convention:

Unique IDs: Every application is identified in the code as name-environment (e.g., blocky-production).

Secret Paths: All secrets must be stored at apps/<app-name>/<environment>/. This makes the "path" a predictable variable.

Automatic Bindings: The OpenBao role will automatically look for a Kubernetes ServiceAccount named <app-name>-sa.

To manage this, I have split the Tofu code into two layers:

The Logic (base/): A template that knows how to create a policy and a role.

The List (production/): A simple map where I just list the app names and their namespaces.

Consequences
Pros:
Speed: Adding a new app (like Linkding or Vaultwarden) now only requires adding its name to a list; the policy and role are created automatically.

Security by Default: Since the paths are standardized, I can't accidentally give an app access to the wrong folder.

Clearer Structure: The base-production-staging hierarchy makes it obvious where global logic lives versus where specific environment settings live.

Cons:
Initial Migration: Because I am changing how Tofu "labels" existing resources, I must use moved blocks to prevent Tofu from deleting my current policies.

Rigidity: I must follow my own naming rules (e.g., I cannot name a ServiceAccount dns-agent if the app is called blocky, or the automation will fail).

# which problems I'm solving with this new implementation?
- Blast Radius (PoLP): blocky-sa can only read blocky secrets.
- Naming Collision: You won't accidentally overwrite a staging secret with a production one because they live in different branches of the Vault tree.
- Auditability: When you run vault audit, you will see exactly which ServiceAccount requested which path.

# logic sequence of steps (AI generated)
- 1. The Role of the locals Block
The locals block is your Internal Source of Truth.

Purpose: It's where you define the "Data" (the list of apps, their namespaces, and paths) separately from the "Logic" (the resource blocks).

Senior Tip: Never put dynamic logic inside variable blocks. Use variables for things that change per environment (like cluster_name) and locals for the "Factory Definition."

2. The Built-in Functions for Your Factory
To make this factory scalable, you’ll use these "Senior" tools:

for_each: The "engine" that iterates over a map and creates one resource for every entry.

for expressions: Used to transform data. For example, taking a list of apps and turning it into a flat map of "App-Environment" pairs.

flatten(): Critical if you have nested data (e.g., multiple apps across multiple environments).

try() / lookup(): For handling optional fields (e.g., if one app needs a special policy but others don't).

3. The Implementation: The "Senior Factory" Pattern
Here is how you would implement this in your infrastructure/tofu/openbao/base/main.tf to mirror your apps/production and apps/staging structure.

# final reasoning 
- mirror my repo directory structure to map and synchronize organization. 
- reducing mental effort by reducing cognitive friction
- adding automation and improving reliability 


