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

The Turnkey adapter is the SDK's multi-chain provider (it advertises `.multiChain`): Solana sentinel chain ids (`RainChain.solanaMainnet` 900 / `solanaDevnet` 901 / `solanaTestnet` 902) route `getWalletAddress(chainId:)`, balances, `sendNative`, `sendToken`, `withdrawCollateral`, and `getTransactions` to the Turnkey Solana account.

- Native SOL and SPL token transfers are both supported end to end. Composition and every preflight live in core's `SolanaTransferComposer` (shared with the Privy adapter, so the two cannot drift); the provider only signs and broadcasts. For an SPL transfer that means: recipient validated as a wallet (not a token account or mint), mint resolved on chain for its decimals and owning token program (classic SPL Token or Token-2022), sender's associated token account derived and checked for balance, recipient's account created in the same transaction when missing (`CreateIdempotent`, ~0.002 SOL rent paid by the sender), SOL-for-fees checked, and the whole thing dry-run with `simulateTransaction` before it is handed over for signing.
- Token-transfer failures surface as their own errors — `tokenNotFound`, `tokenAccountNotFound`, `insufficientTokenBalance`, `invalidRecipient` — which reuse existing `RAIN_*` codes so the code map stays identical to Android's.
- SPL balances come from Turnkey's `get-balances` where it indexes the cluster. Where it doesn't (devnet in particular, where Turnkey answers with SOL only or errors), `getTokenBalances` discovers the wallet's holdings from the node instead: `getTokenAccountsByOwner` against both token programs, summed per mint. Solana has no token registry, so nothing has to be registered up front — but symbol / name stay `nil` unless the mint is registered, since that metadata lives off chain (Metaplex).
- `getTransactions` is sourced from Turnkey's activity log (`ACTIVITY_TYPE_SOL_SEND_TRANSACTION`), matching the EVM path: it lists only what this wallet sent through Turnkey — no receives — and the row's hash is the Turnkey status id, not an explorer-resolvable signature. Both transfer shapes are decoded out of the activity's unsigned transaction: a System transfer becomes a native row (`category: "external"`, `asset: "SOL"`), an SPL `TransferChecked` a token row (`category: "token"`, mint + raw amount + decimals in `rawContract`, `asset` only when the mint is registered — Solana keeps symbols off chain). An SPL transfer's recipient is a token account, so the wallet behind it comes from the transaction's account-creation instruction when present and from one `getAccountInfo` otherwise; if neither resolves, the token account itself is reported rather than dropping the row.
- Turnkey's API hex-decodes the `unsignedTransaction` field (despite the type documenting base64), so Rain serializes the transfer message as hex.
- Turnkey returns a send-status id rather than an on-chain signature; Rain polls the status for the signature and, as a defensive fallback, recovers it from the chain via `getSignaturesForAddress`. That applies to `sendNative` / `sendToken` return values — history rows always carry the status id, since the activity log has no signature.
- **Collateral withdrawal** works on Solana too. Rain's collateral program authorizes a withdrawal differently from the EVM contracts: instead of EIP-712 calldata, the coordinator executor signs a keccak-encoded withdraw message off chain (that is the admin signature the Rain API returns). Core composes a two-instruction transaction — a native ed25519-program instruction proving the executor signed that exact message, then the program's `withdraw_single_signer_collateral_asset` — reading the collateral account, its coordinator's executors, and the mint's token program from the chain, and deriving the collateral-authority PDA and associated token accounts locally. It simulates the result and hands the bytes to the adapter, which signs them **as-is**: re-serializing would invalidate the embedded signature. `withdrawCollateral`'s `proxyAddress` is the collateral account and `tokenAddress` is the SPL mint; only single-signer collateral is supported.

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

## Session expiry, refresh, and retry

Turnkey sessions are short-lived JWTs (15 minutes by default) that die silently once expired.
Rain hardens every Turnkey-backed call against this, controlled by `TurnkeySessionPolicy`:

```swift
TurnkeyProvider(
  TurnkeyConfig(
    turnkey: turnkeyContext,
    sessionPolicy: TurnkeySessionPolicy(
      refreshBufferSeconds: 60,        // refresh when < 60s of lifetime remain
      autoRefresh: true,               // let Rain call Turnkey's refreshSession itself
      refreshExpirationSeconds: nil,   // TTL for refreshed sessions (nil = Turnkey default)
      maxTransientRetries: 2,          // backoff retries for 5xx/429/network on reads
      initialRetryDelay: 0.5,
      maxRetryDelay: 4
    ),
    onSessionExpired: {
      // Re-auth hook: the session died and could not be refreshed. Fired once per
      // session death, off the main thread. Route the user back to login.
    }
  )
)
```

What every wallet call now does:

1. **Expiry check** — the session's JWT `exp` is checked before the request. An
   already-expired session throws `RainSDKError.tokenExpired` (or is refreshed first, see
   below) instead of burning a round-trip on a guaranteed 401.
2. **Proactive refresh** — with `autoRefresh` on (the default), a session expired or inside
   `refreshBufferSeconds` of expiry is refreshed through Turnkey's `refreshSession` before the
   call. Refreshes are single-flighted: concurrent calls share one refresh.
3. **Refresh-on-401** — a call rejected with HTTP 401 / `invalidSession` is refreshed and
   retried exactly once. A 401 means Turnkey rejected the request before executing it, so this
   is safe for sends too. A second 401 surfaces as `RainSDKError.tokenExpired`.
4. **Transient backoff** — idempotent reads (balances, history, transaction-status polls)
   retry HTTP 5xx/429/408 and network failures with exponential backoff. Sends and signing
   are never retried on transient failures.
5. **Re-auth hook** — when the session dies for good (refresh failed, or Turnkey's own expiry
   timer cleared it while the app was idle), `onSessionExpired` fires once — even with no Rain
   call in flight, via a passive watcher over Turnkey's auth state.

With `autoRefresh: false` Rain never touches the session: expired sessions and 401s surface
as `RainSDKError.tokenExpired` immediately and refresh/re-auth is entirely the host's job.

### Observing session state

`TurnkeyProvider` exposes the session as seen at the Rain boundary:

```swift
let provider = TurnkeyProvider(TurnkeyConfig(turnkey: turnkeyContext))

provider.currentSessionState()  // .loading | .active(expiresAt:) | .expired | .unauthenticated

let cancellable = provider.sessionState.sink { state in
  if state == .expired || state == .unauthenticated {
    // show re-login UI
  }
}

try await provider.refreshSession()  // manual refresh; throws .tokenExpired when it fails
```

`sessionState` emits on every Turnkey auth/session change and additionally re-checks when an
active session passes its expiry instant, so a silent death is observable without polling.

When `onSessionExpired` is set, resolving the provider starts a passive watcher over the
process-wide Turnkey singleton. A host that rebuilds the SDK per login should call
`provider.close()` on the provider it is discarding so a stale watcher cannot fire.

Reference: the example app's `RainSDKService.swift`, `WalletSessionStatus.swift` and `HomeView`'s
session card.

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

- **Turnkey ships inside `RainCore`.** Unlike Portal and Privy (separate products), the Turnkey adapter is bundled in `rain-core-ios` for now, so linking `rain-core-ios` pulls Turnkey's Swift SDK. It will graduate to a standalone `rain-turnkey-ios` product later.
- **No dependency conflicts to work around.** Android needs a Bouncy Castle exclusion (Turnkey's and web3j's crypto artifacts collide); the iOS package graph has no equivalent duplicate-symbol issue. The only packaging quirk is a SwiftPM warning about two `secp256k1.swift` forks (from `Web3.swift` and `web3swift`) resolving to the same package identity; it is a warning today and requires no consumer action.
- **Fail-fast resolution.** `TurnkeyProvider.create(context:)` probes the wallet (`address()`) so an unusable context fails at `rain.provider(.turnkey)` time rather than on the first business call.
