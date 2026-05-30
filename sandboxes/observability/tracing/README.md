# Tracing sandboxes

Local instances of distributed-tracing backends. Each sandbox spins up a real
instance, sends a sample trace via OTLP, and verifies the round-trip via the
query API.

## Available

| Tool | Image | Notes |
|---|---|---|
| [jaeger/](jaeger/) | `jaegertracing/all-in-one:latest` | OTLP HTTP + gRPC enabled |

## Planned

| Tool | Self-host story |
|---|---|
| `tempo/` | `grafana/tempo:latest` — pairs with the Grafana sandbox |
| `zipkin/` | `openzipkin/zipkin:latest` — simpler than Jaeger, fewer features |
| `opentelemetry-collector/` | `otel/opentelemetry-collector-contrib:latest` — collector tier in front of any backend |
