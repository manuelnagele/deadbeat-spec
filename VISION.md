# Vision

*Agreed 2026-11-22 (owner: Manuel Nagele).*

## What it is

A **common ground for addon developers on WoW: Forever**, like Titan Panel was for its time: a hub bar that draws the
frame, and modules that fill it. The hub knows nothing about gold, fish or lockouts; modules bring the content.

- **An open spec** says how to integrate: register, claim fields, add badges, contribute tooltip sections, settings
  pages and docked panels, react to contexts. Versioned (semver); modules declare the spec version they target.
- **Two ways in:** the native API for first-class modules, and a **LibDataBroker bridge** so the many existing LDB
  data objects show up without changes.
- **Built for AI-assisted ("vibe-coded") addons too:** an `AGENTS.md` tells an assistant exactly what to do to make
  an addon a module, and a stub harness lets it test without the game client.
- **One neat bar**, never more (2026-11-22): compact in the top middle, or full-width on the top or bottom edge like
  Titan; contexts (farm, raid, dungeon, city, world) decide what shows where.
- **Every setting is a button:** one settings console where each module adds its pages.

## Who it's for

The owner first; published later on GitHub Releases. Code stays clean for that from now on: English, no personal
data, MIT license, nothing that assumes the owner's machine.

## Scope

- **Forever only.** Use whatever WoW: Forever offers (secret values included); no Classic/Retail compatibility work.
- **Hub 1.0 ships with:** the hub (the bar in compact or full-width mode, contexts, settings console, LDB bridge), the spec and
  agent guide, and three public modules: **Hearth** (everyday), **Lockout** (instances per hour), **Catch** (fishing;
  values from vendor prices, richer with a price addon if installed).
- **Private:** the author's own gold-making modules (Haul, Flip, Shop) stay unpublished.

## Not

- Not a UI replacement suite: action bars, unit frames, quest trackers stay with other addons.
- Not a gold-making product: those modules are personal.
- Not multi-flavor.

## Repos

One per addon (deadbeat, hearth, lockout, catch) plus this spec repo.
