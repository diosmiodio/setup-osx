---
description: Deep research and technical analysis of the codebase. Outputs a comprehensive architecture document.
allowed-tools: Task, Bash, Read, Write, Edit, Glob, Grep
---

# Tech Spec

Generate a comprehensive technical architecture document for this codebase. The goal is to produce a reference that a new engineer (or agent) could read to understand how the system works end-to-end.

## Approach

### 1. Discover the major systems

Before diving deep, get oriented. Skim the project structure, read CLAUDE.md and any existing architecture docs, and identify the major technical domains. Typical domains to look for:

- **Networking / API layer** — How do client and server communicate? WebSocket, REST, GraphQL, SSE, RPC.
- **Data storage** — Database schemas, ORM models, in-memory caches, session stores, file storage. Persistent vs ephemeral.
- **External service integrations** — Third-party APIs (LLMs, image generators, payment, analytics). How are they called, what data flows in/out?
- **Client-side architecture** — State management, component relationships, data display patterns.
- **Application lifecycle / phases** — Distinct phases, modes, or states and their transitions.

Adapt to whatever you actually find.

### 2. Research each domain deeply

For each major domain, perform thorough research. Parallelize independent tasks using agents.

Key questions:
- **What exists?** — Enumerate everything exhaustively.
- **How does data flow?** — Trace triggers, inputs, processing, outputs, destinations.
- **What are the connections?** — How do domains interact?
- **What's the lifecycle?** — Creation, use, update, cleanup.

Research tips:
- Search for patterns, not just specific strings. Find one handler, then find all of them.
- Trace both directions: server emitters AND client listeners.
- Note dead code, deprecated paths, and overlapping functionality.
- Include file paths and line numbers.

### 3. Compile into a structured document

Write to `docs/technical-specification.md`.

Include:
- **Overview** — What the application is and high-level structure.
- **Domain deep dives** — Exhaustive catalogs (tables), data flow descriptions, file paths.
- **UML sequence diagrams** — Mermaid diagrams for major flows (multi-party interactions, branching flows, state machines).
- **Cross-cutting observations** — Security concerns, durability gaps, deprecated code, architectural inconsistencies.

### Quality bar

- **Exhaustive, not selective.** Document ALL endpoints, all events, all tables.
- **Concrete, not abstract.** Include actual payload shapes, column names, model names.
- **Traceable.** Include file paths.
- **Honest.** Flag deprecated, broken, or insecure things.
