# data model
- time-series are a combination of metric names and its labels
- The term time series refers to the recording of changes over time. What users want to measure differs from application to application. 
  - For a web server, it could be request times;
  - For a database, it could be the number of active connections or active queries; and so on.
    - usability of time metrics:
      - Example Scenario: when the number of requests is high, the application may become slow.
      - If you have the `request count metric`, you can determine the cause and increase the number of servers to handle the load.
# metric names 
- Metric names SHOULD specify the general feature of a system that is measured (e.g. http_requests_total - the total number of HTTP requests received).
- **coding taxonomy:**
  - Metric names MAY use any UTF-8 characters.
  - Metric names SHOULD match the regex [a-zA-Z_:][a-zA-Z0-9_:]* for the best experience and compatibility (see the warning below). Metric names outside of that set will require quoting e.g. when used in PromQL (see the UTF-8 guide).
# types of metrics 
## counter 
- In programming, `counter `is a variable that you increment each time something happens.

## gauge 
In programming, `gauge` is a variable to which you set a specific value as it changes.
# write data 
## push model 
- the client (application) decides when and where to send its metrics.
  - vm docs recommend using the `github.com/VictoriaMetrics/metrics` package for pushing application metrics to VictoriaMetrics.
### pros & cons 
- pros of push model:
  - Simpler configuration at VictoriaMetrics side 
  - Simpler security setup 
- cons of push protocol:
  - Increased configuration complexity for monitored applications. 
    - Every application needs to be individually configured with the address of the monitoring system for metrics delivery.
      - It also needs to be configured with the interval between metric pushes and the strategy in case of metric delivery failure.
  - Non-trivial setup for metrics’ delivery into multiple monitoring systems.
    - It may be hard to tell whether the application went down or just stopped sending metrics for a different reason.
    - Applications can overload the monitoring system by pushing metrics at too short intervals.
## pull model 
- the **monitoring system** decides when and where to pull metrics from:

- In pull model, the monitoring system needs to be aware of all the applications it needs to monitor.
- The metrics are scraped (pulled) from the known applications (aka scrape targets) via HTTP protocol on a regular basis (aka scrape_interval).
# modify data 
## relabeling 
- Relabeling is a powerful mechanism for modifying time series before they have been written to the database.
  - Relabeling may be applied for both **push and pull models.**
- It allows to prune or rename labels in advance of storage to keep the cardinality low.
- practical application:
  - Learn how to drop useless metadata to save disk space on your NVMe.


# scraping / scrape resources
- 
