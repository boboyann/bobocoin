# Bobocoin — Clarity SIP-010 FT

This project contains a SIP-010 compliant fungible token smart contract for Bobocoin, built and managed with Clarinet.

## Project layout
- `Clarinet.toml` — Clarinet project configuration
- `contracts/sip-010-ft-trait.clar` — Local copy of the SIP-010 fungible token trait
- `contracts/bobocoin.clar` — Bobocoin token implementation (symbol: `BOBO`, decimals: `6`)

## Prerequisites
- Node.js and npm installed

## Install Clarinet
```sh
npm install -g @hirosystems/clarinet
```

If the global install is not available on your PATH, you can also run any command via npx:
```sh
npx @hirosystems/clarinet@latest --version
```

## Verify the contract compiles
From the project root (this directory):
```sh
clarinet check
```
You should see a successful type check with no errors.

## Contract interface (SIP-010)
Read-only:
- `(get-name) -> (response (string-ascii 32) uint)`
- `(get-symbol) -> (response (string-ascii 32) uint)`
- `(get-decimals) -> (response uint uint)`
- `(get-total-supply) -> (response (optional uint) uint)`
- `(get-balance principal) -> (response uint uint)`

Public entry points:
- `(transfer amount sender recipient memo) -> (response bool uint)`
- `(mint amount recipient) -> (response bool uint)` — contract owner only (the deployer)
- `(burn amount sender) -> (response bool uint)` — callable by the token holder

## Try it in the Clarinet console
Start the REPL:
```sh
clarinet console
```
Example session (using default wallets):
```clj
;; Mint 1,000,000 micro-BOBO to wallet_1 (owner-only)
(contract-call? .bobocoin mint u1000000 tx-sender)

;; Transfer 100 micro-BOBO from wallet_1 to wallet_2
(as-contract (contract-call? .bobocoin transfer u100 tx-sender tx-sender none))

;; Read balances
(contract-call? .bobocoin get-balance tx-sender)
```

Notes:
- Error codes: `u100` unauthorized, `u101` insufficient balance, `u102` zero amount, `u103` same sender/recipient.
- Update symbol/decimals in `contracts/bobocoin.clar` if needed.
