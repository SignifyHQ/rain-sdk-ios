# Rain SDK for iOS: Method Reference

Reference for the Rain SDK public API. The SDK is **modular**: `rain-core-ios` (`RainCore`) carries
the vendor-free port, registry, and domain logic; each wallet provider ships as its own adapter
(`PortalProvider`, `PrivyProvider`, and so on; the Turnkey adapter lives inside `RainCore` for now). You
assemble a `RainSdk` with a builder, register the provider adapters your app ships, then resolve a
`RainClient` per provider.

```swift
import RainCore
import RainPortal

let rain = try RainSdk.builder()
    .rpcEndpoints([43114: "https://avalanche-c-chain-rpc.publicnode.com"])
    .register(PortalProvider(PortalConfig(sessionToken: sessionToken)))
    .build()

let client = try await rain.provider(.portal)  // async: RainClient for wallet operations
// Wallet-agnostic transaction building lives on `rain` itself, no provider required.
```

There is no singleton and no `initialize*` methods: a `RainClient` is bound to one provider for
its lifetime. See [TURNKEY_SUPPORT.md](TURNKEY_SUPPORT.md) for the Turnkey adapter walkthrough.

---

## RainSdk

Entry point. Built via `RainSdk.builder()`; the host registers exactly the provider adapters it
ships and the chains it talks to. Nothing here references a concrete vendor type: a provider whose
module isn't linked simply can't be registered.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `providerIds` | `Set<ProviderId>` | Ids of every provider the host registered. |
| `providers` | `[any RainProvider]` | The registered provider descriptors (registration order), for capability resolution. |
| `isRainApiConfigured` | `Bool` | True once a Rain Api-Key and userId have been supplied (builder or `configureRainApi`). |

### Methods

#### builder() -> Builder

Starts a new `Builder`.

#### provider(_ id: ProviderId) async throws -> RainClient

Resolves the `RainClient` backed by the provider registered under `id`, materializing the vendor
wallet on first access and caching it thereafter.

- **Returns:** `RainClient` bound to that provider.
- **Throws:** `RainSDKError.providerNotRegistered` if no provider was registered for `id`.
- **Async:** Yes (materializes the vendor wallet; e.g. Turnkey probes its wallet list).

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | `ProviderId` | The id the provider was registered under (e.g. `.portal`). |

#### first(where:) async throws -> RainClient

Resolves the first registered provider (in registration order) matching the predicate (e.g. by
capability) and returns its `RainClient`.

```swift
let exporter = try await rain.first { $0.capabilities.contains(.export) }
```

- **Returns:** `RainClient` for the first matching provider.
- **Throws:** `RainSDKError.providerNotRegistered` if no registered provider matches.
- **Async:** Yes.

| Parameter | Type | Description |
|-----------|------|-------------|
| `predicate` | `(any RainProvider) -> Bool` | Match tested against each registered provider descriptor. |

#### reset()

Tears down all resolved clients and clears the Rain API credentials. Idempotent.

Mirrors Android's `RainSdk.reset()` as far as the iOS architecture allows: on Android the SDK also
drops its stored chain configuration and must be rebuilt before further use; on iOS the
configuration (network configs, descriptors, token store) is immutable state fixed at `build()`,
so the instance stays usable: the next `provider(_:)` / `first(where:)` call re-resolves the
provider from scratch. Build a new `RainSdk` via `builder()` to change configuration.

- **Async:** No

#### registerTokens(_ tokens: [TokenInfo])

Registers additional tokens on the live token store so their metadata (decimals / symbol / name)
resolves without an on-chain lookup. Also available on the builder (`Builder.registerTokens`).

---

### Wallet-agnostic transaction building

These methods need no resolved provider: they work with any wallet or backend, backed only by
the configured RPC endpoints. (Android exposes the equivalent surface as `rain.transactionBuilder`.)

#### buildEIP712Message(chainId:walletAddress:assetAddresses:amount:decimals:nonce:) async throws -> (String, String)

Builds EIP-712 typed data for the admin signature required for withdrawals.

- **Returns:** `(message, saltHex)`: serialized EIP-712 message and its salt (hex string).
- **Throws:** `RainSDKError` if message construction fails or inputs are invalid.

| Parameter | Type | Description |
|-----------|------|-------------|
| `chainId` | `Int` | Target network chain ID. |
| `walletAddress` | `String` | User wallet address (used as `user` in EIP-712). |
| `assetAddresses` | `EIP712AssetAddresses` | Proxy, recipient, token addresses. |
| `amount` | `Decimal` | Amount in human-readable token units. |
| `decimals` | `Int` | Token decimals. |
| `nonce` | `BigUInt?` | Optional; if `nil`, SDK fetches from contract. |

#### buildWithdrawTransactionData(chainId:assetAddresses:amount:decimals:expiresAt:salt:signatureData:adminSalt:adminSignature:) async throws -> String

Builds ABI-encoded withdraw calldata for the collateral proxy contract.

- **Returns:** `String`: hex-encoded calldata (e.g. `"0x..."`).
- **Throws:** `RainSDKError` if ABI encoding or validation fails.

| Parameter | Type | Description |
|-----------|------|-------------|
| `chainId` | `Int` | Target network chain ID. |
| `assetAddresses` | `WithdrawAssetAddresses` | Contract, proxy, recipient, token addresses. |
| `amount` | `Decimal` | Amount in human-readable token units. |
| `decimals` | `Int` | Token decimals. |
| `expiresAt` | `String` | Expiration as Unix timestamp string or ISO-8601. |
| `salt` | `Data` | Salt data (32 bytes) for the withdrawal authorization. |
| `signatureData` | `Data` | User/wallet signature from the Rain API (65 bytes). |
| `adminSalt` | `Data` | Admin salt from `buildEIP712Message` (32 bytes). |
| `adminSignature` | `Data` | Admin signature authorizing the withdrawal (65 bytes). |

#### buildTransactionParameters(walletAddress:contractAddress:transactionData:) -> RainTransactionParameters

Composes a wallet-agnostic transaction parameter bag for a contract call. Pure helper: returns a
Rain-owned `RainTransactionParameters` struct with `value` pre-set to `"0x0"`. Hosts can hand the
result to any provider for signing / broadcast. (Android's equivalent is
`RainClient.composeTransactionParameters`.)

| Parameter | Type | Description |
|-----------|------|-------------|
| `walletAddress` | `String` | Sender wallet address. |
| `contractAddress` | `String` | Target contract address. |
| `transactionData` | `String` | Hex-encoded calldata. |

---

### Rain API (issuing)

The SDK talks to the Rain issuing API directly: supply a program **Api-Key** and Rain **userId**
(builder `rainApiCredentials(apiKey:userId:)` or `configureRainApi(apiKey:userId:)` at runtime)
and it mints, caches, and refreshes the client session token internally. Credentials are never
persisted. Select the environment with `rainApiEnvironment(_:)` (`.dev` default, `.production`,
`.custom(URL)`).

#### configureRainApi(apiKey:userId:)

Sets or replaces the Api-Key / userId pair at runtime. The cached session token is discarded
lazily; the next API call re-mints against the new pair.

#### fetchCollateralContracts() async throws -> [RainCollateralContract]

Fetches the user's collateral contracts (`GET /v1/issuing/users/{userId}/contracts`). Token
metadata is enriched from the SDK token store or an on-chain read (best-effort).

- **Throws:** `RainSDKError.rainApiNotConfigured` when no credentials were supplied.

#### fetchCollateralContract() async throws -> RainCollateralContract

Convenience for the common single-contract case: the first collateral contract.

- **Throws:** `RainSDKError.noCollateralContracts` when the user has none.

#### fetchAdminSignature(chainId:tokenAddress:amountBaseUnits:adminAddress:recipientAddress:isAmountNative:) async throws -> RainAdminSignature

Fetches the admin withdrawal signature (`GET /v1/issuing/users/{userId}/signatures/withdrawals`)
that authorizes a `withdrawCollateral` call.

- **Throws:** `RainSDKError.signatureNotReady(status:retryAfter:)` while Rain prepares the
  signature; retry after the carried `retryAfter` seconds.

| Parameter | Type | Description |
|-----------|------|-------------|
| `chainId` | `Int` | Target network chain ID. |
| `tokenAddress` | `String` | Token contract address to withdraw. |
| `amountBaseUnits` | `BigUInt` | Withdrawal amount in the token's base units. |
| `adminAddress` | `String` | One of the contract's `adminAddresses`. |
| `recipientAddress` | `String` | Withdrawal recipient. |
| `isAmountNative` | `Bool` | Defaults to `true`. |

---

## RainSdk.Builder

Assembles a `RainSdk`. Module dependencies decide which providers can be registered; the builder
never names a vendor SDK itself.

| Method | Description |
|--------|-------------|
| `rpcEndpoints(_ configs: [NetworkConfig])` | Sets the network configurations every provider shares. **Required.** |
| `rpcEndpoints(_ map: [Int: String])` | Same, from a `chainId → RPC URL` map (parity with Android). |
| `register(_ provider: any RainProvider)` | Registers a provider adapter (e.g. `PortalProvider`, `TurnkeyProvider`, `PrivyProvider`). Re-registering the same id replaces the prior one. |
| `registerTokens(_ tokens: [TokenInfo])` | Seeds the shared token store with extra token metadata. |
| `rainApiEnvironment(_ environment: RainApiEnvironment)` | Selects the Rain issuing API environment (default `.dev`). |
| `rainApiCredentials(apiKey:userId:)` | Optionally supplies the Rain Api-Key / userId at build time. |
| `build() throws -> RainSdk` | Validates endpoints (fail-fast on a bad URL / chain id) and returns the SDK. Throws `RainSDKError.invalidConfig` on invalid RPC endpoints. Providers are optional: building with none yields a wallet-agnostic `RainSdk`. |

### Provider adapters

Each adapter is a `RainProvider` descriptor that owns its vendor SDK as a private dependency.

| Adapter | Module | Config | Notes |
|---------|--------|--------|-------|
| `PortalProvider(PortalConfig(sessionToken:), onPortalCreated:)` | `rain-portal-ios` | `sessionToken: String` | Portal MPC signer (EVM). Advertises `.export`, `.recovery`. The optional `onPortalCreated` hook hands the host the underlying `Portal` instance for Portal-specific APIs (backup / recover). |
| `TurnkeyProvider(TurnkeyConfig(turnkey:walletAddress:))` | `rain-core-ios` | `turnkey: TurnkeyContext`, `walletAddress: String?` | Turnkey P-256 signer (EVM + Solana). Advertises `.multiChain`, `.biometricGate`. See [TURNKEY_SUPPORT.md](TURNKEY_SUPPORT.md). |
| `PrivyProvider(PrivyConfig(privy:walletAddress:))` | `rain-privy-ios` | `privy: any Privy`, `walletAddress: String?` | Privy embedded-key signer (EVM). Advertises `.export`, `.recovery`. Custody routes through Privy's EIP-1193 embedded wallet; balance/fee reads use Rain's configured RPC. |

#### Platform differences (Portal)

Both adapters construct the vendor `Portal` with `autoApprove = true`,
`FeatureFlags(isMultiBackupEnabled = true)`, and the same `eip155:<chainId> → rpcUrl` RPC config.
Two differences are vendor-shaped and intentional:

- **Storage backends.** PortalSwift takes iCloud / keychain / password storage at construction, so
  the iOS adapter passes `ICloudStorage()`, `PortalKeychain()`, and `PasswordStorage()` there.
  portal-android registers backup storage at backup-call time instead, so the Android adapter
  passes none at construction.
- **`chainId`.** Android's `PortalConfig` has an optional `chainId` because portal-android's
  constructor accepts a legacy `legacyEthChainId`; PortalSwift 7.x has no equivalent parameter, so
  iOS's `PortalConfig` omits it.

**Bring your own provider:** implement the `RainWalletProvider` port and a `RainProvider`
descriptor (with your own `ProviderId`), then `register(...)` it. Core needs no change; the
wallet-agnostic building methods are available regardless of which provider you register.

---

## RainClient

Operations Rain exposes against a single, already-resolved wallet provider. Obtained from
`rain.provider(_:)` / `rain.first { … }`; bound to one provider for its lifetime, so it carries no
`initialize*` methods and never references a concrete vendor type.

Money APIs are `Decimal`-first: human-unit amounts and fees are `Decimal` everywhere (exact
base-10, no binary floating-point drift). Older `Double` variants survive only as deprecated shims.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `providerId` | `ProviderId` | Identifier of the provider backing this client (e.g. `.portal`). |
| `capabilities` | `Set<Capability>` | Optional behaviours the backing provider supports (see [Capabilities](#capabilities)). |
| `isInitialized` | `Bool` | Whether the SDK's chain configuration is set up. On iOS a client only exists once its provider resolved against a validated configuration, so this is always `true` for a live client (Android parity). |

---

### withdrawCollateral(chainId:assetAddresses:amount:decimals:salt:signature:expiresAt:nonce:)

Full withdrawal flow: builds the calldata, obtains the admin EIP-712 signature via the backing
provider, submits on-chain, and returns the transaction hash.

- **Returns:** `String`: transaction hash.
- **Throws:** `RainSDKError` if construction, signing, or submission fails.
- **Async:** Yes

| Parameter | Type | Description |
|-----------|------|-------------|
| `chainId` | `Int` | Target network chain ID (e.g. `43114`). |
| `assetAddresses` | `WithdrawAssetAddresses` | Contract, proxy, recipient, token addresses. |
| `amount` | `Decimal` | Amount in human-readable token units (e.g. `100`). |
| `decimals` | `Int` | Token decimals (e.g. 6 for USDC, 18 for most tokens). |
| `salt` | `String` | Salt for the user's withdrawal authorization (base64, 32 bytes decoded), from `fetchAdminSignature`. |
| `signature` | `String` | User/wallet signature from the Rain API (hex, 65 bytes). |
| `expiresAt` | `String` | Expiration as Unix timestamp string or ISO-8601. |
| `nonce` | `BigUInt?` | Optional; if `nil`, SDK resolves from contract. |

> Android differs in shape here: it takes a `RainAdminSignature` value and an `autoSend` flag and
> signs during the call; iOS takes the caller-supplied `salt` / `signature` / `expiresAt` fields.

---

### getWalletAddress()

Returns the current wallet address from the backing provider.

- **Returns:** `String`: hex-encoded wallet address (e.g. `"0x..."`).
- **Throws:** `RainSDKError` if the address cannot be retrieved.
- **Async:** Yes

---

### getWalletAddress(chainId:)

Returns the wallet address for a specific chain's family. For EVM chains this is the same hex
address as `getWalletAddress()`. A provider that also holds non-EVM accounts (advertising
`.multiChain`) returns the address matching `chainId`'s family, e.g. a base58 Solana address for
a Solana sentinel chain id (101 / 102 / 103). EVM-only providers return the hex address regardless.

- **Parameters:** `chainId: Int`
- **Returns:** `String`: the wallet address for that chain's family.
- **Throws:** `RainSDKError` if the address cannot be retrieved.
- **Async:** Yes

---

### estimateGas(chainId:from:to:data:)

Estimates the gas fee required for a transaction.

- **Returns:** `Decimal`: estimated gas fee in the chain's native token (e.g. AVAX).
- **Throws:** `RainSDKError` if estimation fails.
- **Async:** Yes

| Parameter | Type | Description |
|-----------|------|-------------|
| `chainId` | `Int` | Target network chain ID. |
| `from` | `String` | Sender wallet address. |
| `to` | `String` | Target contract address. |
| `data` | `String` | Hex-encoded transaction calldata (e.g. from `buildWithdrawTransactionData`). |

---

### estimateWithdrawalFee(chainId:addresses:amount:decimals:salt:signature:expiresAt:)

Estimates the total fee required to execute a collateral withdrawal transaction.

Internally builds + signs the EIP-712 payload, then runs `eth_estimateGas` against the withdrawal
controller; it does not broadcast.

- **Returns:** `Decimal`: estimated withdrawal fee in the chain's native token.
- **Throws:** `RainSDKError` if estimation fails.
- **Async:** Yes

| Parameter | Type | Description |
|-----------|------|-------------|
| `chainId` | `Int` | Target network chain ID. |
| `addresses` | `WithdrawAssetAddresses` | All addresses required for the withdrawal. |
| `amount` | `Decimal` | Human-readable amount to withdraw. |
| `decimals` | `Int` | Token decimals. |
| `salt` | `String` | Salt for the user's withdrawal authorization (base64, 32 bytes decoded). |
| `signature` | `String` | User/wallet signature from the Rain API (hex, 65 bytes). |
| `expiresAt` | `String` | Expiration as Unix timestamp string or ISO-8601. |

---

### sendNative(chainId:to:amount:)

Sends native tokens (e.g. ETH, AVAX, SOL) from the current wallet. Routed by `chainId`: Solana
sentinel chain ids (101 / 102 / 103) go through the provider's Solana path when it supports one.

- **Returns:** `RainTokenTransferResult`: carrying the transaction hash (EVM) or signature (Solana).
- **Throws:** `RainSDKError` if the send fails or the provider does not support the chain family.
- **Async:** Yes

| Parameter | Type | Description |
|-----------|------|-------------|
| `chainId` | `Int` | Target network chain ID (EVM id or Solana sentinel). |
| `to` | `String` | Recipient address (hex on EVM, base58 on Solana). |
| `amount` | `Decimal` | Amount in human-readable form (e.g. `0.1` for 0.1 AVAX). |

---

### sendToken(chainId:contractAddress:to:amount:decimals:)

Sends ERC-20 (EVM) or SPL (Solana) tokens from the current wallet. Routed by `chainId`.

- **Returns:** `RainTokenTransferResult`: carrying the transaction hash.
- **Throws:** `RainSDKError` if the send fails.
- **On Solana:** supported by the providers that hold a Solana account (Turnkey and Privy; Portal
  throws). `decimals` is ignored — the mint's on-chain value is authoritative — and a recipient with
  no token account for the mint gets an associated one created in the same transaction, paid for by
  the sender. The transfer is dry-run against the cluster before signing, so a doomed send fails as
  `tokenNotFound` / `tokenAccountNotFound` / `insufficientTokenBalance` / `invalidRecipient` /
  `transactionSimulationFailed` rather than silently failing on chain.
- **Async:** Yes

| Parameter | Type | Description |
|-----------|------|-------------|
| `chainId` | `Int` | Target network chain ID. |
| `contractAddress` | `String` | ERC-20 contract address (EVM) or SPL mint address (Solana). |
| `to` | `String` | Recipient wallet address. |
| `amount` | `Decimal` | Amount in human-readable form (e.g. `100` for 100 USDC). |
| `decimals` | `Int?` | Optional token decimals. When omitted / `nil`, the SDK resolves the token's `decimals()` from its registry or an on-chain read, so callers don't have to track it. |

---

### Balance value type

All balance methods return rich `Balance` values rather than lossy `Double`s.

| Field | Type | Description |
|-------|------|-------------|
| `token` | `Token` | `.native` or `.contract(address:)`. |
| `chainId` | `Int` | Chain ID the balance was read on. |
| `rawAmount` | `BigUInt` | Exact balance in the token's smallest unit (never lossy). |
| `decimals` | `Int` | Token decimal places (e.g. 6 for USDC, 18 for ETH). |
| `symbol` | `String?` | Token symbol, when known. |
| `name` | `String?` | Human-readable name, when known. |
| `decimalAmount` | `Decimal` | Derived: `rawAmount / 10^decimals`. |
| `formatted` | `String` | Derived display string (e.g. `"1.5"`). |

---

### getBalance(chainId:token:)

Fetches a single balance (native or a contract token) for the current wallet.

- **Returns:** `Balance`: exact `rawAmount` plus resolved decimals / symbol / name.
- **Throws:** `RainSDKError` if the request fails.
- **Async:** Yes

| Parameter | Type | Description |
|-----------|------|-------------|
| `chainId` | `Int` | Target network chain ID (e.g. `43114` for Avalanche Mainnet). |
| `token` | `Token` | `.native`, or `.contract(address:)` (address comparison is case-insensitive). |

---

### getTokenBalances(chainId:)

Fetches all non-zero balances for the current wallet on the given network. The native balance is
always included; zero-balance contract tokens are omitted. Supersedes the deprecated
`getBalances(chainId:)`, which returned a lossy `[String: Double]`.

- **Returns:** `[Balance]`: one per non-zero token plus the native balance.
- **Throws:** `RainSDKError` if the request fails.
- **Async:** Yes

| Parameter | Type | Description |
|-----------|------|-------------|
| `chainId` | `Int` | Target network chain ID. |

---

### getAllBalances()

Fetches balances across every configured chain in parallel, flattened into a single list. Each
`Balance` carries its own `chainId`. Per-chain failures are tolerated: a chain that errors out
contributes no entries rather than failing the whole call.

- **Returns:** `[Balance]`: a flat list spanning all healthy configured chains.
- **Throws:** `RainSDKError` if the request fails.
- **Async:** Yes

---

### generateAddressQRCode(address:dimension:backgroundColor:foregroundColor:)

Generates a square QR code image (PNG) encoding `address` — or the wallet's own address when
`address` is `nil`. Use it for any address the host shows: a chain-specific wallet address (the
Solana account rather than the EVM one) or a Rain collateral deposit address.

A convenience overload, `generateAddressQRCode(address:)`, applies the defaults below.

- **Returns:** `Data`: PNG image bytes.
- **Throws:** `RainSDKError` if the wallet address is needed but unavailable, or QR generation fails.
- **Async:** Yes

| Parameter | Type | Description |
|-----------|------|-------------|
| `address` | `String?` | Address to encode; `nil` uses the provider's wallet address. |
| `dimension` | `Int` | Output width/height in pixels (`256` via the convenience overload). |
| `backgroundColor` | `CGColor?` | Optional; default black. |
| `foregroundColor` | `CGColor?` | Optional; default white. |

---

### generateWalletAddressQRCode(dimension:backgroundColor:foregroundColor:)

Generates a square QR code image (PNG) encoding the current wallet address — the same as
`generateAddressQRCode(address: nil, …)`.

- **Returns:** `Data`: PNG image bytes.
- **Throws:** `RainSDKError` if the wallet is unavailable or QR generation fails.
- **Async:** Yes

| Parameter | Type | Description |
|-----------|------|-------------|
| `dimension` | `Int` | Output width/height in pixels (default `256`). |
| `backgroundColor` | `CGColor?` | Optional; default black. |
| `foregroundColor` | `CGColor?` | Optional; default white. |

---

### getTransactions(chainId:limit:offset:order:)

Fetches transaction history for the current wallet on the given network.

- **Returns:** `[WalletTransaction]`: transaction records (hash, from, to, value, category, metadata, chainId, …). `value` is a `Decimal?` in human-readable units.
- **Throws:** `RainSDKError` if transaction history cannot be retrieved.
- **On Solana:** rows cover native SOL (`category: "external"`) and SPL tokens
  (`category: "token"`, with the mint, raw amount and decimals in `rawContract`); token accounts are
  reported as the wallets behind them where they can be resolved. What is listed depends on the
  provider's source: Turnkey reads its own activity log, so only sends made through the SDK appear,
  with the Turnkey status id as the hash.
- **Async:** Yes

| Parameter | Type | Description |
|-----------|------|-------------|
| `chainId` | `Int` | Target network chain ID. |
| `limit` | `Int?` | Optional max number of transactions to return. |
| `offset` | `Int?` | Optional pagination offset. |
| `order` | `WalletTransactionOrder?` | Optional sort order: `.ASC` or `.DESC`. |

---

### reset()

Clears client-held state. On iOS a resolved client is immutable (configuration and the backing
provider are fixed at resolution), so this is an idempotent no-op that exists for parity with
Android's `RainClient.reset()`. Prefer `RainSdk.reset()`, which evicts resolved clients so they
re-resolve on next access.

- **Async:** No

---

## Deprecated (compatibility shims)

Source-compat shims retained so code written against 1.0.0 keeps compiling with only deprecation
warnings. Each delegates to the precise current API and collapses the result to the old shape.
Slated for removal in the next major version.

| Deprecated | Replacement | Notes |
|------------|-------------|-------|
| `sendToken(chainId:contractAddress:to:amount: Double, decimals: Int)` | `sendToken(chainId:contractAddress:to:amount:)` | `amount` is now `Decimal`; `decimals` optional (SDK resolves it). |
| `sendERC20Token(chainId:contractAddress:to:amount:decimals:) -> String` | `sendToken(...)` | Returns the `.transactionHash` String. |
| `sendNativeToken(chainId:to:amount:) -> String` | `sendNative(chainId:to:amount:)` | Returns the `.transactionHash` String. |
| `getNativeBalance(chainId:) -> Double` | `getBalance(chainId:, token: .native)` | Read `.decimalAmount` for exact precision. |
| `getERC20Balance(chainId:tokenAddress:decimals:) -> Double` | `getBalance(chainId:, token: .contract(address:))` | `decimals` argument ignored; SDK resolves decimals itself. |
| `getERC20Balances(chainId:) -> [String: Double]` | `getTokenBalances(chainId:)` | Drops the native entry; non-zero ERC-20s only, as `Double`. |
| `getBalances(chainId:) -> [String: Double]` | `getTokenBalances(chainId:)` | Lossy `Double` map keyed by contract address; native under the `""` key. |
| `RainSdk.composeTransactionParameters(...) -> ETHTransactionParam` | `buildTransactionParameters(...)` | Lives in `RainPortal`; maps the Rain-owned result to Portal's `ETHTransactionParam`. |
| `EthereumConverter.parseHexToDouble(_:decimals:)` | `EthereumConverter.parseHexToDecimal(_:decimals:)` | `Double` loses precision above 2^53 base units. |

---

## Capabilities

A provider advertises optional behaviours via `Capability`, so hosts can resolve by feature
(`rain.first { $0.capabilities.contains(.export) }`) and degrade gracefully instead of assuming a
capability every provider has.

| Capability | Meaning |
|------------|---------|
| `.export` | The wallet's key material can be exported / backed up. |
| `.recovery` | The wallet supports a recovery ceremony. |
| `.multiChain` | The provider holds accounts across multiple chain families (e.g. EVM + Solana). |
| `.biometricGate` | Signing is gated behind a device biometric / passkey prompt. |

Bundled providers: **Portal** → `.export`, `.recovery`. **Turnkey** → `.multiChain`,
`.biometricGate`. **Privy** → `.export`, `.recovery`.

---

## Types

| Type | Description |
|------|-------------|
| **`ProviderId`** | Struct wrapping a provider id string. Well-known constants: `.portal`, `.turnkey`, `.privy`. Host apps can ship a custom id. |
| **`Capability`** | Enum: `.export`, `.recovery`, `.multiChain`, `.biometricGate`. |
| **`RainProvider`** | Registrable provider descriptor: `id`, `capabilities`, and an async `create(context:)` that materializes the `RainWalletProvider`. Implemented by `PortalProvider`, `TurnkeyProvider`, `PrivyProvider`, and host-supplied providers. |
| **`RainWalletProvider`** | The port each adapter implements. Public so hosts can ship their own wallet stack. |
| **`NetworkConfig`** | `chainId`, `rpcUrl`, optional `networkName`. Also constructible from an `eip155:<chainId>` string. |
| **`EIP712AssetAddresses`** | `proxyAddress`, `recipientAddress`, `tokenAddress`. |
| **`WithdrawAssetAddresses`** | `contractAddress`, `proxyAddress`, `recipientAddress`, `tokenAddress`. |
| **`RainAdminSignature`** | `salt` (String), `signature` (hex String), `expiresAt` (String, ISO-8601 or Unix timestamp). Returned by `fetchAdminSignature`. |
| **`RainCollateralContract`** | Collateral contract from the Rain API: addresses, admin set, tokens (with enriched metadata). |
| **`RainApiEnvironment`** | `.dev` (default), `.production`, `.custom(URL)`. |
| **`RainTokenTransferResult`** | `transactionHash` (String): on-chain hash (EVM) or signature (Solana). Returned by `sendNative` and `sendToken`. |
| **`RainTransactionParameters`** | `from`, `to`, `value` (hex wei), `data` (hex calldata). Wallet-agnostic parameter bag returned by `buildTransactionParameters`. |
| **`Token`** | `.native` or `.contract(address:)`; contract equality is case-insensitive. |
| **`TokenInfo`** | `chainId`, `address`, `symbol?`, `decimals`, `name?`. Used to seed the token store. |
| **`Balance`** | Exact balance value type; see [Balance value type](#balance-value-type). |
| **`WalletTransaction`** | Transaction record: `hash`, `from`, `to`, `value` (`Decimal?`), `blockNum`, `category`, `rawContract`, `metadata`, `chainId`, etc. Returned by `getTransactions`. |
| **`WalletTransactionOrder`** | Enum: `.ASC`, `.DESC`. Used in `getTransactions(..., order:)`. |

---

## Errors

All async methods can throw `RainSDKError`. Each error includes an `errorCode` property for
programmatic handling.

| Code | Case | Meaning |
|------|------|--------|
| `RAIN_101` | `sdkNotInitialized` | Operation called before the SDK's configuration was set up. |
| `RAIN_102` | `invalidConfig(chainId:rpcUrl:)` / `providerNotRegistered(details:)` | Invalid RPC URL or chain ID; no provider registered for the requested id; or no provider matched a capability. |
| `RAIN_103` | `invalidRpcUrl(_:)` | RPC URL could not be parsed as a valid URL. |
| `RAIN_104` | `rainApiNotConfigured` | A Rain API method was called before an Api-Key and userId were supplied. |
| `RAIN_201` | `tokenExpired` | Provider session token expired or invalid. |
| `RAIN_202` | `unauthorized` | Invalid or missing token / permissions. |
| `RAIN_301` | `networkError(underlying:)` | Network/connectivity failure. |
| `RAIN_302` | `apiError(statusCode:message:)` | The Rain API returned a non-success HTTP status (other than 401/403 → `unauthorized`). |
| `RAIN_303` | `signatureNotReady(status:retryAfter:)` | The withdrawal admin signature is not ready yet; retry after `retryAfter` seconds. |
| `RAIN_304` | `noCollateralContracts` | The contracts endpoint returned no collateral contracts for the configured user. |
| `RAIN_401` | `userRejected` | User cancelled the signing request in the wallet. |
| `RAIN_402` | `insufficientFunds(required:available:)` | Balance too low for the requested amount or gas. |
| `RAIN_403` | `transactionSimulationFailed(underlying:)` | Preflight `eth_call` simulation failed (e.g. contract revert, insufficient funds). |
| `RAIN_404` | `walletUnavailable` | The backing provider returned no usable wallet address. |
| `RAIN_405` | `withdrawalRevertedByNetwork` | Withdrawal reverted on-chain (e.g. duplicate withdrawal, already-used signature). |
| `RAIN_406` | `invalidAmount(amount:reason:)` | The amount is invalid for the token (more decimal places than the token supports, or unrepresentable). |
| `RAIN_407` | `walletNotAuthorized(walletAddress:proxyAddress:)` | The signing wallet is not an admin of the collateral contract. |
| `RAIN_501` | `providerError(underlying:)` | Portal, Turnkey, Privy, or other provider error. |
| `RAIN_502` | `internalLogicError(details:)` | EIP-712 encoding, ABI encoding, or internal processing error. |

### Error handling example

```swift
do {
    let client = try await rain.provider(.portal)
    let txHash = try await client.withdrawCollateral(...)
} catch let error as RainSDKError {
    switch error {
    case .providerNotRegistered: /* Unknown provider id */ break
    case .insufficientFunds: /* Not enough balance */ break
    case .networkError(let underlying): /* Network issue */ break
    default: print("\(error.errorCode): \(error.localizedDescription)")
    }
}
```
