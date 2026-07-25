# Rain SDK iOS

[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)](#installation)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-not--supported-lightgrey)](#installation)
[![Carthage](https://img.shields.io/badge/Carthage-not--supported-lightgrey)](#installation)

iOS SDK with first-class [Portal](https://portalhq.io), [Turnkey](https://www.turnkey.com), and
[Privy](https://privy.io) wallet support: build EIP-712 messages, compose withdrawal transactions,
sign and submit through a registered wallet provider, read balances and history, and estimate fees.
Works on EVM chains and Solana.

The SDK is **modular** (ports & adapters): a vendor-free **`RainCore`** plus one adapter module per
wallet provider. Link only the providers you use — an unselected provider's vendor SDK never enters
your dependency graph.

| Module        | Contains                                                                 |
|---------------|--------------------------------------------------------------------------|
| `RainCore`    | The `RainWalletProvider` port, capability model, provider registry (`RainSdk`), all Rain domain logic, **and the Turnkey adapter** (`TurnkeyProvider`, for now). |
| `RainPortal`  | The Portal MPC adapter (`PortalProvider`); depends on `RainCore` + `PortalSwift`. |
| `RainPrivy`   | The Privy embedded-key adapter (`PrivyProvider`); depends on `RainCore` + the Privy iOS SDK (`Privy`). Custody (sign/send) routes through Privy's EIP-1193 embedded wallet; balance/fee reads use Rain's configured RPC. |
| `RainSDK`     | Backward-compat umbrella that re-exports `RainCore` + `RainPortal` (migration only; prefer the specific modules). |

## Features

- **Portal wallet integration** — Register a `PortalProvider` with a Portal session token; resolve a `RainClient` and use the connected MPC wallet for signing and sending transactions.
- **Turnkey wallet integration** — Register a `TurnkeyProvider` with an authenticated `TurnkeyContext` (passkeys / auth proxy / OAuth / OTP handled outside Rain by the Turnkey Swift SDK).
- **Privy wallet integration** — Register a `PrivyProvider` with an authenticated `Privy` singleton (auth + embedded-wallet provisioning handled outside Rain by the Privy iOS SDK); custody routes through Privy's EIP-1193 embedded wallet.
- **Pluggable providers** — Bring your own `RainWalletProvider` behind a `RainProvider` descriptor and register it; resolve providers by id or by `Capability`.
- **Wallet-agnostic utilities** — EIP-712 message + withdraw calldata building are available straight off `RainSdk` with no provider resolved — use them with your own wallet or backend.
- **EIP-712 message building** — Build typed data for admin signature required by the collateral contract.
- **Withdrawal transaction building** — Build ABI-encoded withdraw calldata for submission.
- **Solana support** — native SOL and SPL transfers, balances, history, and collateral withdrawal, on the same `RainClient` methods as EVM. See [Solana](#10-solana).
- **Full withdrawal flow** — builds the transaction, signs via the backing provider, and submits; returns the transaction hash.
- **Fee estimation** — returns the estimated gas cost in the chain’s native token (e.g. ETH).
- **Wallet information** — get the wallet address (per chain family) and generate a QR code image (PNG) for it or for any other address.
- **Balances** — get native, ERC-20, and SPL token balances for the current wallet.
- **Transaction history** — get transactions for the current wallet with optional pagination and sort order (`WalletTransaction`, `WalletTransactionOrder`).
- **Send tokens** — send native, ERC-20, or SPL tokens from the current wallet.
- **Exact money handling** — public money APIs are `Decimal`; base-unit conversion is exact and rejects an amount finer than the token's scale rather than truncating it.

## Installation

### Swift Package Manager

Add the package in Xcode (**File → Add Package Dependencies**) with:

```
https://github.com/SignifyHQ/rain-sdk-ios
```

Or in a `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SignifyHQ/rain-sdk-ios", from: "1.0.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "RainSDK", package: "rain-sdk-ios")
    ])
]
```

Today the repo vends the **`RainSDK`** umbrella product (re-exports `RainCore` + `RainPortal`) — use
it and `import RainCore` / `import RainPortal` as needed. The per-provider modules (`RainCore`,
`RainPortal`, `RainPrivy`) are published as standalone packages so you can depend on **only the
providers you use** — an unselected provider's vendor SDK never enters your dependency graph:

```swift
// Portal-only app: RainCore comes transitively; Privy/Turnkey vendor SDKs are never resolved.
.package(url: "https://github.com/SignifyHQ/rain-portal-ios", from: "1.0.0"),
// Or for Privy (pulls the Privy iOS SDK; Portal's vendor SDK is never resolved):
// .package(url: "https://github.com/SignifyHQ/rain-privy-ios", from: "1.0.0"),
// Or for Turnkey (the adapter ships inside RainCore for now):
// .package(url: "https://github.com/SignifyHQ/rain-core-ios", from: "1.0.0"),
```

New code should depend on the specific modules; `RainSDK` exists for migration only.

## Migrating from 1.x

v2 is a **source-breaking** release. The `RainSDK` umbrella keeps `import RainSDK` resolving
(module-level compatibility), but the 1.x entry point was replaced — there are no shims for it:

| 1.x | v2 |
|---|---|
| `RainSDKManager()` | `RainSdk.builder().rpcEndpoints(…).register(…).build()` |
| `initializePortal(portalSessionToken:networkConfigs:)` | `.register(PortalProvider(PortalConfig(sessionToken:)))` + `rain.provider(.portal)` |
| `initializeTurnkey(turnkey:networkConfigs:walletAddress:)` | `.register(TurnkeyProvider(TurnkeyConfig(turnkey:)))` + `rain.provider(.turnkey)` |
| `initialize(networkConfigs:)` (wallet-agnostic) | `RainSdk.builder().rpcEndpoints(…).build()` — building methods live on `RainSdk` |
| `manager.portal` accessor | `PortalProvider(_, onPortalCreated:)` hook |
| `manager.turnkey` accessor | none — the host already owns its `TurnkeyContext` |
| `setWalletProvider` | none: a resolved `RainClient` is immutable; register multiple providers and resolve each instead |
| `reset()` | `RainSdk.reset()`, which tears down resolved clients (they re-resolve on next access) and clears Rain API credentials |

Business methods (`sendToken`, `withdrawCollateral`, balances, …) kept their names on
`RainClient`; renamed/retyped 1.x variants remain as deprecated shims (see `Deprecated.swift`
in `RainCore` and `RainPortal`).

## Requirements

- iOS 17.0+
- Swift 6.1+
- Xcode 16.3+

## Usage

### 1. Portal (full wallet flow)

Register a `PortalProvider` and resolve a `RainClient`.

```swift
import RainCore
import RainPortal

let rain = try RainSdk.builder()
    .rpcEndpoints([
        1: "https://mainnet.infura.io/v3/YOUR_KEY",
        137: "https://polygon-rpc.com",
    ])
    .register(PortalProvider(PortalConfig(sessionToken: "<your-portal-session-token>")))
    .build()

// Resolve the Portal-backed client (suspends — materializes the wallet on first access).
let client = try await rain.provider(.portal)
```

### 2. Turnkey (full wallet flow)

Turnkey authentication happens **outside** Rain — drive Turnkey's Swift SDK (auth proxy / passkeys /
OAuth / OTP), then hand the authenticated `TurnkeyContext` to Rain:

- Proxy middleware: `https://docs.turnkey.com/sdks/swift/proxy-middleware`
- Passkeys: `https://docs.turnkey.com/sdks/swift/register-passkey`

```swift
import RainCore
import TurnkeySwift

let rain = try RainSdk.builder()
    .rpcEndpoints([43114: "https://avalanche-c-chain-rpc.publicnode.com"])
    .register(
        TurnkeyProvider(
            TurnkeyConfig(
                turnkey: turnkeyContext,
                walletAddress: nil // omit to use the first Ethereum account from the context
            )
        )
    )
    .build()

let client = try await rain.provider(.turnkey)
```

### 3. Bring your own provider, or resolve by capability

The registry is designed for the multi-provider case; a single-provider app is just the trivial
`N = 1` instance of it. Register your own `RainWalletProvider` behind a `RainProvider` descriptor,
then resolve by id or by capability:

```swift
// …or resolve the first registered provider with a given capability
let exporter = try await rain.first { $0.capabilities.contains(.export) }
```

### 4. Wallet-agnostic building (no provider resolved)

EIP-712 message and withdraw calldata building are available directly off `RainSdk`:

```swift
let (message, salt) = try await rain.buildEIP712Message(
    chainId: 1, walletAddress: "0x…", assetAddresses: addresses,
    amount: 100, decimals: 6, nonce: nil
)
```

### 5. Get wallet address

```swift
let address = try await client.getWalletAddress()

// Per-chain family — returns the Solana account for Solana sentinel chains, the EVM address otherwise:
let solAddress = try await client.getWalletAddress(chainId: solanaChainId)
```

### 6. Read balances

Balances are returned as rich `Balance` values that carry the exact base-unit `rawAmount`
(a `BigUInt`, never lossy) alongside resolved `decimals`/`symbol`/`name` and convenience
`decimalAmount` / `formatted` accessors. A `Token` is either `.native` or `.contract(address:)`.

```swift
// A single balance (native or a specific token):
let eth = try await client.getBalance(chainId: 1, token: .native)
let usdc = try await client.getBalance(
    chainId: 1,
    token: .contract(address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")
)
print(usdc.formatted)       // e.g. "1.5"
print(usdc.rawAmount)       // exact base units, e.g. 1500000

// Every non-zero balance on a chain (native is always included):
let balances = try await client.getTokenBalances(chainId: 1)

// Every balance across all configured chains, flattened (each Balance carries its chainId):
let all = try await client.getAllBalances()
```

Token metadata for well-known tokens is built in. To resolve a token the SDK doesn't know
about without an on-chain `decimals()` / `symbol()` lookup, register it up front on the builder:

```swift
RainSdk.builder()
    .registerTokens([
        TokenInfo(chainId: 1, address: "0x…", symbol: "FOO", decimals: 18, name: "Foo Token")
    ])
    // …
```

Unregistered contract tokens are still resolved automatically by reading `decimals()` /
`symbol()` on-chain once, then cached.

### 7. Send tokens

Both return a `RainTokenTransferResult` carrying the `transactionHash`.

```swift
// Native token (e.g. ETH, AVAX):
let native = try await client.sendNative(chainId: 1, to: "0x…", amount: 0.1)
print(native.transactionHash)

// ERC-20 (EVM) / SPL (Solana) — omit `decimals` to let the SDK resolve them:
let erc20 = try await client.sendToken(
    chainId: 1, contractAddress: "0x…", to: "0x…", amount: 100
)
```

### 8. Rain API: collateral contracts & admin signature

The SDK talks to the Rain issuing API directly — supply your program **Api-Key** and Rain
**userId** and it handles session (CST) minting, caching, and refresh internally. Credentials
are never persisted by the SDK. In production, prefer minting server-to-server and keeping the
Api-Key off the device.

```swift
let rain = try RainSdk.builder()
    .rpcEndpoints([84532: "https://sepolia.base.org"])
    .rainApiEnvironment(.dev) // default; .production / .custom(URL) available
    .rainApiCredentials(apiKey: "…", userId: "…") // or configureRainApi(...) at runtime
    .build()

// Or set / replace credentials later (e.g. entered in your UI):
rain.configureRainApi(apiKey: "…", userId: "…")

// GET /v1/issuing/users/{userId}/contracts — token name/symbol/decimals are enriched from
// the SDK token store or an on-chain read (best-effort; nil when unresolvable)
let contract = try await rain.fetchCollateralContract()   // first, or RainSDKError.noCollateralContracts
let contracts = try await rain.fetchCollateralContracts() // full list

// GET /v1/issuing/users/{userId}/signatures/withdrawals
// Throws RainSDKError.signatureNotReady(status:retryAfter:) while Rain prepares the signature.
let adminSignature = try await rain.fetchAdminSignature(
    chainId: contract.chainId,
    tokenAddress: contract.tokens[0].address,
    amountBaseUnits: BigUInt(100_000_000), // base units
    adminAddress: contract.adminAddresses[0],
    recipientAddress: "0x…"
)
// adminSignature.salt / .signature / .expiresAt feed withdrawCollateral below
```

### 9. Withdraw collateral

Signs the admin EIP-712 message via the backing provider, submits, and returns the tx hash.

```swift
let addresses = WithdrawAssetAddresses(
    contractAddress: "0x…",
    proxyAddress: "0x…",
    recipientAddress: "0x…",
    tokenAddress: "0x…"
)

let txHash = try await client.withdrawCollateral(
    chainId: 1,
    assetAddresses: addresses,
    amount: 100,
    decimals: 6,
    salt: "…",
    signature: "…",
    expiresAt: "2024-12-31T23:59:59Z",
    nonce: nil // omit to read the latest nonce on-chain
)
```

For manual submission (build the calldata yourself, no provider resolved), use the wallet-agnostic
`rain.buildWithdrawTransactionData(...)` from section 4.

### 10. Solana

Solana uses the same `RainClient` methods as EVM — the SDK routes on the chain ID. `RainChain`
exposes the sentinel IDs (`solanaMainnet` 900, `solanaDevnet` 901, `solanaTestnet` 902); these are
Rain's routing IDs, not Solana chain IDs. Register a Solana RPC URL against them like any other
chain. `RainChain.isSolana(_:)` and `solanaCaip2(for:)` are available if the host needs to branch.

```swift
let client = try await rain.provider(.turnkey)   // or .privy; Portal has no Solana account
let chainId = RainChain.solanaDevnet

try await client.getWalletAddress(chainId: chainId)        // the Solana account, not the EVM address
try await client.getBalance(chainId: chainId, token: .native)   // SOL
try await client.getTokenBalances(chainId: chainId)             // SPL holdings
try await client.sendNative(chainId: chainId, to: recipientBase58, amount: 0.01)
try await client.sendToken(
    chainId: chainId,
    contractAddress: mintAddress,
    to: recipientBase58,
    amount: 1.5
)
```

`withdrawCollateral` works unchanged, with `proxyAddress` as the collateral account and
`tokenAddress` as the SPL mint (`contractAddress` is unused — there is no coordinator contract to
call). Under the hood the withdrawal is authorized by Rain's coordinator signing a message off chain
rather than by EVM calldata, so the SDK composes and simulates a collateral-program transaction and
the provider signs it. See [TURNKEY_SUPPORT.md](docs/TURNKEY_SUPPORT.md#solana-notes) for details.

An SPL mint's decimals are read from the chain, so a `decimals` argument is a hint only. Mints carry
no on-chain symbol — `registerTokens(_:)` names the ones you want displayed.
### 11. Estimate withdrawal fee

Returns the estimated total fee in the chain's native token (e.g. ETH).

```swift
let fee = try await client.estimateWithdrawalFee(
    chainId: 1,
    addresses: addresses,
    amount: 100,
    decimals: 6,
    salt: "…",
    signature: "…",
    expiresAt: "2024-12-31T23:59:59Z"
)
print("Estimated fee: \(fee)")
```

### 12. Transaction history

```swift
let txs = try await client.getTransactions(
    chainId: 1,
    limit: 20,
    offset: 0,
    order: .DESC
)
for tx in txs {
    print("\(tx.hash) — \(tx.from) → \(tx.to ?? "—")")
}
```

### 13. QR code generation

Returns PNG `Data` encoding any address — pass `nil` (or omit it) for the wallet's own address.

```swift
// The wallet's own address, 256 px, default colours.
let walletPNG = try await client.generateAddressQRCode()

// A specific address — e.g. the Solana account, or a Rain collateral deposit address.
let depositPNG = try await client.generateAddressQRCode(address: contract.depositAddress)

// Full control over size and colours.
let large = try await client.generateAddressQRCode(
    address: try await client.getWalletAddress(chainId: RainChain.solanaDevnet),
    dimension: 500,
    backgroundColor: nil, // defaults applied when nil
    foregroundColor: nil
)
let image = UIImage(data: walletPNG)
```

For a short overview of all public methods, see [Method overview](docs/METHODS.md).

## License

See the [LICENSE](LICENSE) file for details.
