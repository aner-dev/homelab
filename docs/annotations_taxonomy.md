### C. Telemetry & Observability (VictoriaMetrics & Grafana Stack)
| Key | Example Values | Strategic Purpose |
| :--- | :--- | :--- |
| `athanor.io/scrape` | `"true"`, `"false"` | Global target discoverability indicator for `VMAgent`. |
| `athanor.io/scrape-port` | `"9090"` | Overrides target port definitions for non-standard exporters. |
| `athanor.io/telemetry-path` | `"/stats"` | Instructs `VMAgent` to seek alternative endpoint targets. |
| `athanor.io/log-format` | `"json"`, `"text"` | Instructs `Loki` parsing pipelines on processing formats. |
| `athanor.io/log-retention` | `"14d"` | Implements custom TTL overrides for intensive logging endpoints. |
| `grafana_dashboard` | `"1"` | Intercepted by Grafana sidecars to auto-provision JSON configmaps. |


