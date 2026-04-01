---
name: wol vs wol-realm architecture
description: wol is the stateless connection interface (telnet/WSS), wol-realm is the game engine; they are separate repos and hosts
type: project
---

wol and wol-realm are distinct services with separate repos and infrastructure hosts.

- **wol** (`wol/` repo): Stateless connection interface (C#/.NET). Handles telnet, TLS telnet, WS, WSS on port 6969. Dual-homed (external :6969, internal for APIs). Designed for horizontal autoscaling. Calls API services directly on the private network via mTLS (not through the gateway). UID 1006, IP 10.0.0.30+, SPIFFE ID `spiffe://wol/server-a`. Deploys `Wol.Server.dll`.

- **wol-realm** (`wol-realm/` repo): Game engine. Runs the MUD world simulation (rooms, NPCs, combat, ticks, game logic). Internal-only single-homed service on private network. UID 1001, IP 10.0.0.20, SPIFFE ID `spiffe://wol/realm-a`. Deploys `Wol.Realm.dll`.

- **wol-gateway** (10.0.0.8): Pure network infrastructure only (NAT + DNS + NTP). No Envoy, no SPIRE Agent, no workload identity, no service user.

**Why:** The user corrected that wol is NOT the game server. It only passes information back and forth for client connections. wol-realm is where the actual game runs.

**How to apply:** Never conflate wol with the game engine. When discussing game server logic, that's wol-realm. When discussing client connections, telnet/WSS protocols, or autoscaling, that's wol. The gateway has no application-layer services.
