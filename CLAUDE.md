# Claude Code Instructions

## Git
- Never commit or push changes unless explicitly asked.

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
- `RainTurnkey` (`rain-turnkey-ios`) — Turnkey BYO adapter (multi-chain EVM+Solana; `.multiChain`,
  `.biometricGate`). `RainPortal` (`rain-portal-ios`) — Portal MPC, EVM-only.
  `RainPrivy` (`rain-privy-ios`) — Privy embedded wallet (EIP-1193 custody, reads via Rain RPC).
- Adapters follow one shape: descriptor + config, wallet adapter over the vendor SDK, session
  coordinator/policy (`onSessionExpired`), error mapping registered via
  `RainSDKError.registerErrorMapper` from the provider's init. Auth happens OUTSIDE Rain; the host
  hands in an authenticated vendor object.
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

`rain-wallet-ios` / `RainWallet`: Rain-branded provider on top of RainTurnkey with embedded Rain
org id + auth-proxy config id (placeholders first); wallet-neutral naming; auth INSIDE the SDK —
email OTP only (decided) via Turnkey's auth proxy. Public surface: `RainWallet` auth façade,
`RainWalletConfig`, descriptor struct `RainProvider`, id `ProviderId.rain`, neutral session
surface (`RainWalletSessionState`, publisher, refreshSession). RainWallet @_exported imports
RainCore only — NEVER RainTurnkey (no Turnkey symbol on a bare `import RainWallet`). Needs
`TurnkeyErrorMapping.registerOnce` widened to @_spi. `TurnkeyContext` is a process-wide singleton
⇒ RainWallet and BYO RainTurnkey mutually exclusive; guard in `RainSdk.build()`.
