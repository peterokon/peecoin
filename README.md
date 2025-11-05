# Peecoin (SIP-010 fungible token)

Peecoin is a SIP-010 compliant fungible token implemented in Clarity and managed with Clarinet.

## Project layout

- `Clarinet.toml` — Clarinet project manifest
- `contracts/sip010-trait.clar` — SIP-010 trait interface (local copy)
- `contracts/peecoin.clar` — Peecoin token implementation

## Prerequisites

- Linux or macOS
- Clarinet CLI
  - If you already have Rust/Cargo: `cargo install --locked clarinet`
  - Or use the official installer script (no sudo):
    - `curl -fsSL https://raw.githubusercontent.com/hirosystems/clarinet/main/install.sh | bash`
    - Ensure the installer’s bin directory is on your PATH (commonly `~/.local/bin` or `~/.clarinet/bin`).

Verify installation:

```bash
clarinet --version
```

## Getting started

From the project root:

```bash
clarinet check
```

This compiles and type-checks all contracts.

### Open a console and interact

```bash
clarinet console
```

Inside the console you can use preset accounts (e.g. `deployer`, `wallet_1`, ...):

- Mint tokens (owner-only, the `deployer` is the contract owner):

```clarity
::contract-call? .peecoin mint wallet_1 u100000
```

- Check balances and metadata:

```clarity
::contract-call? .peecoin get-balance wallet_1
::contract-call? .peecoin get-name
::contract-call? .peecoin get-symbol
::contract-call? .peecoin get-decimals
::contract-call? .peecoin get-total-supply
```

- Transfer tokens (must be called by the `sender`):

```clarity
::as wallet_1 ::contract-call? .peecoin transfer u250 wallet_1 wallet_2 none
::contract-call? .peecoin get-balance wallet_2
```

- Burn your own tokens:

```clarity
::as wallet_1 ::contract-call? .peecoin burn u100
```

## Contract overview

The contract implements the SIP-010 trait with the following public/read-only functions:

- `transfer(amount, sender, recipient, memo)` → `(response bool uint)`
- `get-name()` → `(response (string-ascii 32) uint)`
- `get-symbol()` → `(response (string-ascii 10) uint)`
- `get-decimals()` → `(response uint uint)`
- `get-balance(principal)` → `(response uint uint)`
- `get-total-supply()` → `(response (optional uint) uint)`
- `get-token-uri()` → `(response (optional (string-utf8 256)) uint)`

Additional admin/user helpers:

- `mint(recipient, amount)` — owner-only mint
- `burn(amount)` — burn from caller’s balance

## Notes

- Initial supply is zero; the owner can mint to desired recipients.
- Error codes:
  - `u100` not authorized
  - `u101` insufficient funds
  - `u102` zero-amount not allowed
