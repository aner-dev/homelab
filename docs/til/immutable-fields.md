# immutable fields (kustomization files)


# change selectors
In HA (high-availability) production, we almost never change selectors. Why? Because if you change the selector, the Deployment "loses track" of its existing pods, which can cause an outage.
