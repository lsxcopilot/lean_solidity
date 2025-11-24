## Purpose

This repository is a minimal Solidity contract source (see `test.sol`). These instructions help an AI coding assistant be immediately productive: understand the project's scope, follow local conventions, and produce small, well-scoped edits.

## Repo snapshot

- Primary source: `test.sol` — contains only:
  - `// SPDX-License-Identifier: MIT`
  - `pragma solidity ^0.8;`

There are no build configs (no `package.json`, `foundry.toml`, or `hardhat` config) and no tests present.

## What to assume and what *not* to change without direction

- Assume code targets Solidity 0.8.x (use language features and safeties available in 0.8).
- Preserve the SPDX license header and pragma unless the user requests a different target.
- Do not add large frameworks (Foundry/Hardhat) automatically — propose them first and wait for approval.

## Helpful, concrete actions the assistant can take

- Small feature additions or fixes inside `test.sol` (add a contract, functions, events) that are self-contained and compile with Solidity ^0.8.
- Add documentation comments (NatSpec) above contracts/functions when introducing new code.
- When adding storage or public APIs, explain gas/visibility tradeoffs inline in the PR description.

## Build / quick checks (explicit, minimal)

Use the Solidity compiler directly for quick verification (no framework required):

```sh
# compile and show binary+abi for test.sol with solc
solc --optimize --combined-json abi,bin test.sol
```

If the user later adds a repo-specific toolchain (Foundry/Hardhat), switch to the declared commands in the repo.

## Code patterns & conventions to follow (from this repo)

- Keep files single-purpose and minimal. `test.sol` implies the repo prefers very small, explicit sources.
- Use SPDX header and explicit pragma in every new `.sol` file.

## Examples of safe, actionable edits

- Add a simple contract skeleton that compiles with ^0.8 and includes NatSpec comments.
- Add an internal helper or small library as a separate `.sol` file and import it from `test.sol`.

## When to ask the user

- Before introducing any new build system, test framework, or CI integration.
- Before changing the license or lowering/raising the compiler pragma.

## PR / commit guidance for generated changes

- Keep changes small and self-contained. Each PR should include:
  1. A one-line summary.
  2. Why the change was needed.
  3. How it was tested (solc output, short description).

## If you need more context

- Ask for the intended use of the contract (token, vault, toy example) and preferred tooling (Foundry/Hardhat/Truffle).

---
If anything here is unclear or you want me to include recommended project scaffolding (Foundry/Hardhat) and CI snippets, tell me which toolchain you prefer and I will propose a minimal, reversible change set.
