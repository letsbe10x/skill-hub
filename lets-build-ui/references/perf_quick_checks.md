# Frontend performance quick checks (practical)

- Avoid layout shift on load (reserve image and component space).
- Prefer transform/opacity for animations; avoid animating layout properties.
- Lazy-load below-the-fold media where appropriate.
- Keep interaction latency low (no expensive work on click/scroll).
