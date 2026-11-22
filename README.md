# Deadbeat spec

The open spec for **Deadbeat**, a hub bar for WoW: Forever in the spirit of Titan Panel: one shared place on screen
where any addon can sit as a module. This repo holds the vision, the versioned spec, the agent guide for building a
module with an AI assistant, the stub test harness and an example module.

- [VISION.md](VISION.md): where this is going and what it is not
- [ROADMAP.md](ROADMAP.md): milestones
- [PROCESS.md](PROCESS.md): how work is done across the repos
- [spec.md](spec.md): the spec, 1.0 (Deadbeat 1.0)
- [AGENTS.md](AGENTS.md): for AI assistants (and people) turning an addon into a module
- [harness/](harness/): the stubbed WoW API for tests outside the game
- [examples/hello](examples/hello): the example module, every part of the API once

Tests: `luajit tests/harness.lua` (needs a deadbeat checkout at `../deadbeat` or `$DEADBEAT`);
`cd examples/hello && luajit tests/smoke.lua`.

License: MIT.
