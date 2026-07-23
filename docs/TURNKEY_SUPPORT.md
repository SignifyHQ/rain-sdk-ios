# Turnkey Support

Rain SDK for iOS supports [Turnkey](https://turnkey.com) as a wallet provider, alongside the Portal MPC and Privy adapters. Turnkey ships as the `TurnkeyProvider` adapter, which currently lives inside the `rain-core-ios` module (`RainCore`). Turnkey authentication (passkeys, OAuth, OTP, auth proxy) happens **outside** Rain: the host app uses the official [Turnkey Swift SDK](https://docs.turnkey.com/sdks/swift/getting-started) to authenticate the user and then hands the live `TurnkeyContext` to Rain via `TurnkeyConfig` for wallet operations.

## Requirements

- iOS 17.0+ (Rain SDK's platform floor; Turnkey's Swift SDK requires iOS 16+, so Rain's floor governs).
- Swift 6.1+ / Xcode 16.3+.
- Turnkey Swift SDK initialized and authenticated by the host app (passkey / auth-proxy / OAuth / OTP flow completed) before the `TurnkeyContext` is handed to Rain.

## Adding the dependency

The Turnkey products ship transitively with `rain-core-ios`, so consumers don't need to add them explicitly. Internally Rain pins:

```
https://github.com/tkhq/swift-sdk.git (exact 4.0.0)
  products: TurnkeySwift, TurnkeyHttp, TurnkeyTypes
```

## Architectural split

Rain SDK's public Turnkey surface is exactly one boundary: registering a `TurnkeyProvider(TurnkeyConfig(turnkey:walletAddress:))` with the `RainSdk` builder, then resolving `rain.provider(.turnkey)`. Everything *before* that (`TurnkeyContext` setup, OTP/passkey/OAuth flows, sub-org provisioning, wallet creation) is host-app code, written against Turnkey's own Swift SDK. This split keeps Rain free of Turnkey's auth-UI surface.

| Layer | Who owns it | Examples |
|---|---|---|
| Authentication (pre-register) | Your app | Turnkey Swift SDK: proxy middleware, passkey registration, OTP / OAuth login, `createWallet` |
| Hand-off | Boundary | `RainSdk.builder().register(TurnkeyProvider(TurnkeyConfig(turnkey: context, …)))` → `rain.provider(.turnkey)` |
| Wallet operations (post-resolve) | Rain SDK | `client.getWalletAddress()`, `getBalance(chainId:token:)`, `sendNative(...)`, `withdrawCollateral(...)` |

Turnkey's Swift guides for the pre-register half:

- Proxy middleware: `https://docs.turnkey.com/sdks/swift/proxy-middleware`
- Passkeys: `https://docs.turnkey.com/sdks/swift/register-passkey`

## Reference glue (example app)

The example app's `RainSDKService.swift` (`Example/RainSDKDemo/RainSDKDemo/Core/Services/RainSDKService.swift`) shows the full hand-off: it accepts a `TurnkeyContext` whose `authState == .authenticated`, builds the SDK, and resolves the client:

```swift
import RainCore
import TurnkeySwift

let rain = try RainSdk.builder()
    .rpcEndpoints([
        43114: "https://avalanche-c-chain-rpc.publicnode.com",
        43113: "https://avalanche-fuji-c-chain-rpc.publicnode.com"
    ])
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

`rain.provider(_:)` is `async`: resolving the Turnkey provider probes the Turnkey wallet list (refreshing it once if needed) and throws `RainSDKError.walletUnavailable` if no usable Ethereum account is available. You can register other adapters (e.g. `PortalProvider`, `PrivyProvider`) on the same builder and resolve each independently; providers do not replace one another.

### Host contract for the `TurnkeyContext`

`TurnkeyConfig` is `@unchecked Sendable` because `TurnkeyContext` is a host-owned reference type with mutable published state that Rain reads from arbitrary executors. The contract: finish authentication **before** handing the context to Rain, and don't mutate it (re-auth, logout, wallet switch) while Rain calls are in flight; after such changes, build a new `RainSdk` or re-resolve the provider.

## What Rain uses Turnkey for

After the Turnkey-backed `client` is resolved, every wallet operation routes through Turnkey:

| Rain operation | Turnkey API used |
|----------------|------------------|
| `client.getWalletAddress()` | `TurnkeyContext.wallets` (first Ethereum-format account; cached after first resolve) |
| `client.getWalletAddress(chainId:)` (Solana sentinel ids) | `TurnkeyContext.wallets` (first Solana-format account, base58) |
| `client.getBalance(chainId:, token: .native)` | `getWalletAddressBalances` (CAIP-19 `slip44:` filter) on supported chains; RPC `eth_getBalance` otherwise |
| `client.getBalance(chainId:, token: .contract(...))` | RPC `eth_call` (`balanceOf`) via the shared chain reader |
| `client.getTokenBalances(chainId:)` | `getWalletAddressBalances` (CAIP-19) on supported chains; Multicall3 / parallel `eth_call` otherwise |
| `client.sendNative(...)` / `client.sendToken(...)` (EVM) | `ethSendTransaction` + `getSendTransactionStatus` polling |
| `client.sendNative(...)` (Solana) | `solSendTransaction` + status polling, with an RPC signature-recovery fallback |
| `client.withdrawCollateral(...)` | `TurnkeyContext.signRawPayload` (EIP-712) + `ethSendTransaction` |
| `client.getTransactions(...)` | `getActivities` (filtered to `ACTIVITY_TYPE_ETH_SEND_TRANSACTION`, or `ACTIVITY_TYPE_SOL_SEND_TRANSACTION` on Solana ids) |
| `client.estimateGas(...)` / `estimateWithdrawalFee(...)` | RPC `eth_estimateGas` + `eth_gasPrice` (exact `BigUInt`/`Decimal` math) |

Chains covered by Turnkey's `get-balances` API (Ethereum, Sepolia, Base, Base Sepolia, Polygon, Polygon Amoy, plus Solana clusters) read balances through Turnkey; any other configured chain falls through to Rain's chain reader over your RPC endpoints.

## Solana notes

The Turnkey adapter is the SDK's multi-chain provider (it advertises `.multiChain`): Solana sentinel chain ids (101 mainnet / 102 testnet / 103 devnet) route `getWalletAddress(chainId:)`, balances, `sendNative`, and `getTransactions` to the Turnkey Solana account.

- Native SOL transfers are supported end to end; SPL token transfers are **not yet implemented** on iOS: `sendToken` with a Solana chain id throws `RainSDKError.internalLogicError`.
- Turnkey's API hex-decodes the `unsignedTransaction` field (despite the type documenting base64), so Rain serializes the transfer message as hex.
- Turnkey returns a send-status id rather than an on-chain signature; Rain polls the status for the signature and, as a defensive fallback, recovers it from the chain via `getSignaturesForAddress`.

## Signing

EIP-712 signing uses `TurnkeyContext.signRawPayload` with `.payload_encoding_eip712` + `.hash_function_no_op`. Rain normalizes the returned `r`, `s`, `v` components into a `0x`-prefixed 65-byte hex signature compatible with `eth_signTypedData_v4` responses (recovery id auto-adjusted to the 27/28 range when needed).

## Accessing the Turnkey instance

Rain exposes no vendor getters (core references no concrete vendor type). You already own the `TurnkeyContext` (it's the instance you authenticated and passed to `TurnkeyConfig`), so keep your own reference for advanced Turnkey operations (export, session management, extra wallets).

## Error handling

Turnkey-specific errors are mapped into the standard `RainSDKError` hierarchy (see `RainSDKError+Mapping.swift` in `RainCore`):

| Turnkey error | Mapped to |
|---------------|-----------|
| `TurnkeySwiftError.invalidSession` | `RainSDKError.tokenExpired` |
| `TurnkeyRequestError.apiError` with HTTP 401 | `RainSDKError.tokenExpired` |
| `TurnkeyRequestError.apiError` with HTTP 403 | `RainSDKError.unauthorized` |
| `TurnkeyRequestError.network` | `RainSDKError.networkError` |
| Config / setup errors (`invalidConfiguration`, `missingAuthProxyConfiguration`, `invalidRefreshTTL`, `publicKeyMissing`, `signingNotSupported`, `invalidJWT`, `invalidResponse`, `keyAlreadyExists`, `keyNotFound`, `keyIndexFailed`, `keychainAddFailed`, `oauthInvalidURL`, `oauthMissingIDToken`) | `RainSDKError.internalLogicError` |
| Wrapper errors (`failedToSignPayload`, `failedToFetchWallets`, …) | Unwrapped recursively; e.g. a wrapped `ASAuthorizationError.canceled` (passkey prompt dismissed) surfaces as `RainSDKError.userRejected` |
| Anything else | `RainSDKError.providerError` |

Network errors raised during direct RPC calls (balances, fee estimation) surface as `RainSDKError.networkError`.

## Registering alongside Portal or Privy

Adapters are not mutually exclusive. Register several on the same builder and resolve each to its own `RainClient`: one SDK instance, independent provider-bound clients:

```swift
import RainCore
import RainPortal

let rain = try RainSdk.builder()
    .rpcEndpoints(endpoints)
    .register(PortalProvider(PortalConfig(sessionToken: portalSessionToken)))
    .register(TurnkeyProvider(TurnkeyConfig(turnkey: turnkeyContext)))
    .build()

let portalClient = try await rain.provider(.portal)
let turnkeyClient = try await rain.provider(.turnkey)
```

Each client is bound to its provider for its lifetime; there is no "active provider" to swap.

## iOS-specific integration notes

- **Turnkey ships inside `RainCore`.** Unlike Portal and Privy (separate packages), the Turnkey adapter is bundled in `rain-core-ios` for now, so depending on `RainCore` pulls Turnkey's Swift SDK. It will graduate to a standalone `rain-turnkey` module later.
- **No dependency conflicts to work around.** Android needs a Bouncy Castle exclusion (Turnkey's and web3j's crypto artifacts collide); the iOS package graph has no equivalent duplicate-symbol issue. The only packaging quirk is a SwiftPM warning about two `secp256k1.swift` forks (from `Web3.swift` and `web3swift`) resolving to the same package identity; it is a warning today and requires no consumer action.
- **Fail-fast resolution.** `TurnkeyProvider.create(context:)` probes the wallet (`address()`) so an unusable context fails at `rain.provider(.turnkey)` time rather than on the first business call.
