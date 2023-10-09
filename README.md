# Breath

A set of tools for **network game development** in dart/flutter.  
*At the moment this is mostly Oxygen with network support.*

- Targets flutter/web for the client
- Targets dart/desktop for the - authoritative - server

Glueing websockets, [Flame](https://github.com/flame-engine/flame) & [Oxygen](https://github.com/flame-engine/oxygen).

## Tasks

- Frame rewinder
- Fixed-step loop + helpers
- Tweening helpers (Dead reckoning, smoothing)
- Integrate QUIC whenever there is a dart lib
- Avoiding codegen for now but might build my own ECS w/ codegen (trying to avoid that rabbit hole for now 🙈)