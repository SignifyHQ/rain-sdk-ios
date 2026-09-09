# Claude Code Instructions

## Git
- Never commit or push changes unless explicitly asked.
- Commit messages: single line only, no body. No conventional-commit prefixes (no `feat:`/`fix(scope):`). Always start with a capital letter.

## Build & test
- Test command: `xcodebuild -scheme RainSDK-Package -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test` (always use the iPhone 17 Pro simulator).

## Architecture (post Turnkey extraction, 2026-09-03)

Modular, ports & adapters. One SPM package (internal name `RainSDK`), one product per provider;
clients link only the providers they use. Every adapter `@_exported import`s RainCore, so one
import per provider suffices. The 1.x `RainSDK` umbrella module has been REMOVED.

- `RainCore` (`rain-core-ios`) — vendor-free hexagon: `WalletProvider` port, `ProviderDescriptor`
  descriptors, `Capability` model, `RainSdk` builder/registry (caches in-flight resolution Tasks),
  `RainClient` (impl `RainSdkManager`), transaction building, EIP-712, EVM chain reader
  (JSON-RPC + Multicall3), Solana stack (sentinel ids 900/901/902), token store, Rain issuing API
  (CST sessions, collateral contracts, admin signatures), Auth Pull (ERC-20 allowance surface),
  error model. No wallet vendor SDKs.
- `RainTurnkey` (`rain-turnkey-ios`) — Turnkey adapter, BYO + managed modes (multi-chain
  EVM+Solana; `.multiChain`, `.biometricGate`). `RainPortal` (`rain-portal-ios`) — Portal MPC,
  EVM-only. `RainPrivy` (`rain-privy-ios`) — Privy embedded wallet (EIP-1193 custody, reads via
  Rain RPC). `RainWallet` (`rain-wallet-ios`) — Rain-branded provider: a wallet-neutral renaming
  layer over managed RainTurnkey (descriptor struct `RainProvider`, id `.rain`, host-supplied
  `RainWalletConfig(organizationId:authConfigId:)`); `@_spi(RainWallet) internal import RainTurnkey`
  so no vendor type can leak into its public surface (compiler-enforced), @_exported RainCore
  only; mutually
  exclusive with `.turnkey` (guard in `RainSdk.build()`). Test seams for managed providers:
  `TurnkeyManagedConfigurator.configureImpl` + `.sharedContext` (the vendor singleton traps
  unconfigured in test hosts).
- Adapters follow one shape: descriptor + config, wallet adapter over the vendor SDK, session
  coordinator/policy (`onSessionExpired`), error mapping registered via
  `RainSDKError.registerErrorMapper` from the provider's init. Portal/Privy: auth happens OUTSIDE
  Rain (host hands in an authenticated vendor object). Turnkey has two modes: BYO (same), and
  MANAGED — `TurnkeyConfig(organizationId:authProxyConfigId:)`, SDK configures the TurnkeyContext
  singleton (one-shot per process, TurnkeyManagedConfigurator) and TurnkeyProvider exposes email-OTP
  auth (sendLoginCode/confirmLoginCode/logout/authState) + EVM/Solana wallet provisioning on login.
- SPI convention: adapter modules reach core internals via `@_spi(RainAdapter) import RainCore`
  (`ChainReader`/`MinedReceipt`, `ProviderContext.evmChainReader`, `RainSolanaSupport` seams,
  `SolanaRpcClient`, `SolanaTransferComposer`, `JsonRpcClient`, `SolanaTransactionDecoder`,
  `SolanaConverter`, `TokenMetadataStore.init`, `String.strippingHexPrefix`,
  `RainChain.solanaNativeCurrency`). Not API for host apps. Note: public types don't get Sendable
  inference — declare it when widening. Tests touching SPI symbols need
  `@_spi(RainAdapter) @testable import RainCore`.
- Test targets can `@testable import` any package target but not other test targets — each
  adapter's test target duplicates the helpers it needs (TestFixtures, MockChainReader,
  MockURLProtocol, etc.).

## Naming (renamed 2026-09-04, PR A of the RainWallet work)

The `RainWallet*` namespace belongs exclusively to the upcoming Rain-branded module. Renames:
port `RainWalletProvider` -> `WalletProvider`; descriptor protocol
`RainProvider` -> `ProviderDescriptor` (NO typealias — the name is reserved for the new module's
descriptor struct). No typealiases at all: both renames are clean breaks in the v5 release.

## Planned next

Phase 2 (replanned 2026-09-07) — auth moves INSIDE the SDK for Turnkey and RainWallet:

- PR B1 (DONE 2026-09-07; reworked 2026-09-09), RainTurnkey managed auth — SPI-only: `TurnkeyConfig`
  gains a managed init (`organizationId` + `authProxyConfigId`) alongside the existing BYO
  authenticated-context init (kept, non-breaking). Managed mode: the SDK calls
  `TurnkeyContext.configure` itself (singleton, process-guarded) and `TurnkeyProvider` exposes
  auth — email OTP only: `sendLoginCode(email:)` / `confirmLoginCode(_:)` (initOtp → verifyOtp +
  completeOtp under a per-attempt session key, login-or-signup; wrong code = `invalidLoginCode`
  RAIN_203, never a logout), `logout()`, `authState` publisher mapped to a Rain-owned enum.
  Provisioning: ONE wallet with both the Ethereum and Solana accounts (single seed; atomic at
  signup via `createSubOrgParams.customWallet`, backfilled onto the existing seed via
  `create_wallet_accounts` otherwise) — a cross-platform contract with Android. Auth calls in
  BYO mode throw invalidConfig. DECISION 2026-09-09: the managed surface (managed init, auth
  extension, `TurnkeyAuthState`) is `@_spi(RainWallet)` — publicly Turnkey is BYO-only like
  Portal/Privy; managed auth ships to hosts exclusively through RainWallet, whose module uses
  `@_spi(RainWallet) internal import RainTurnkey`. Demo Turnkey tab stays full BYO
  (TurnkeyAuthSample drives the vendor SDK); managed email-OTP is demoed on the Rain Wallet tab.
- PR B2 (DONE 2026-09-07), `rain-wallet-ios` / `RainWallet`: pure renaming layer over managed RainTurnkey — NO
  embedded ids; `RainWalletConfig(organizationId:authConfigId:)` is host-supplied (Rain issues the
  values to partners). Descriptor struct `RainProvider`, id `ProviderId.rain`, neutral session
  surface (`RainWalletSessionState`, publisher, refreshSession). RainWallet @_exported imports
  RainCore only — NEVER RainTurnkey (no Turnkey symbol on a bare `import RainWallet`). Mutual
  exclusion guard in `RainSdk.build()` (.rain + .turnkey cannot both register — one TurnkeyContext
  per process). Vendor concealment is naming-level only (no embedded config anymore). Demo app
  gains a RainWallet provider option (4th tab/flow: org id + auth config id entry, email OTP via
  the RainWallet methods, then the standard wallet screens), linking rain-wallet-ios.
