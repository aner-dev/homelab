Use `tofu apply -out=prod.tfplan` is a better practice than `tofu apply`
The `prod.tfplan` is a file intended to be ephemeral and recreated
Its a 'snapshot in time'

Each `tofu apply` makes the previous useless file
# reasoning: 🔍 Why a previous plan becomes "useless"?
In a production environment, the infrastructure is a moving target.
If you generate a plan at 10:00 AM and someone else manually changes a setting in the Vault UI at 10:05 AM, your 10:00 AM plan is now stale (outdated).
# prod.tfplan utility 
- OpenTofu safety:
  - If you try to apply a plan that is based on an old version of the state, OpenTofu will actually stop you and say: "The state has changed since this plan was created."

- Recreation:
  - Every time you run tofu plan -out=..., it overwrites the old file with the absolute latest "diff" between your code and the real world.
# CI/CD pipeline ('Single Use' rule)
- In a professional CI/CD pipeline:
1. The plan file is created during the "Check" phase.
2. It is passed as an "artifact" to the "Deploy" phase.
3. Once the apply is finished, the .tfplan file is usually deleted. It has served its purpose. It is never reused for the next deployment.
