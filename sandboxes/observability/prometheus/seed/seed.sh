#!/usr/bin/env bash
# Prometheus needs no explicit seed — the self-scrape config in prometheus.yml
# produces metrics from the moment the server starts. This script exists for
# contract consistency with the other sandboxes and to allow future enrichment
# (e.g. pushing metrics via a pushgateway service if added to compose).
set -euo pipefail
echo "✓ no explicit seed required; Prometheus self-scrape produces metrics automatically"
