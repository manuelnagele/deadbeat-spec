# Process

- **Issues and milestones** in each repo; the owner prioritizes, the assistant picks from them.
- **Branches + PRs** into `main`; CI (LuaJIT tests in GitHub Actions) must be green; `main` is what the gaming box
  follows (each addon's `*-sync` service).
- **In-game checklist** in every PR: what to verify in the real client (the stub tests can't see it). A PR is done
  when the owner confirms the checks.
- **Versioned releases:** tags `vX.Y.Z` with a changelog; packaged zips on GitHub Releases from milestone 5 on.
- Specs and decisions for the hub live in this repo.
