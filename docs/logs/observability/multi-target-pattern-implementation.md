- I find this observability pattern pretty similar to a CI pipeline "healtchecker workflow", albeit they are like **"spiritual cousings"** more than analogous approaches."
# comparison between both (markdown table)

|**Feature**|**CLI Script / CI Check**|**Multi-Target Exporter Pattern**|
|---|---|---|
|**Philosophy**|**Gatekeeping:** "Don't let this merge if it's broken."|**Observation:** "How has this performed over the last 7 days?"|
|**Execution**|**Ephemeral:** Starts, checks, dies.|**Persistent:** Always running, waiting for VM to ask.|
|**Output**|**Exit Code:** 0 (Pass) or 1 (Fail).|**Metrics:** Latency (ms), Status, TLS expiry, etc.|
|**Data Type**|**Event-based.**|**Time-series.**|
