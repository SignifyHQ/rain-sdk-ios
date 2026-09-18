# Claude Code Instructions

## Git
- Never commit or push changes unless explicitly asked.
- Commit messages: single line only, no body. No conventional-commit prefixes (no `feat:`/`fix(scope):`). Always start with a capital letter.
- PR descriptions: human voice — first person, plain sentences, brief; cover the substance without exhaustive bullet inventories or marketing polish.

## Build & test
- Test command: `xcodebuild -scheme RainSDK-Package -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test` (always use the iPhone 17 Pro simulator).

## Architecture (post Turnkey extraction, 2026-09-03)

Modular, ports & adapters. One SPM package (internal name `RainSDK`), one product per provider;
clients link only the providers they use. Every adapter `@_exported import`s RainCore, so one
import per provider suffices. The 1.x `RainSDK` umbrella module has been REMOVED.

- `RainCore` (`rain-core-ios`) — vendor-free hexagon: `WalletProvider` port, `ProviderDescriptor`
  descriptors, `Capability` model, `RainSdk` builder/registry (caches in-flight resolution Tasks),
  `RainClient` (impl `RainSdkManager`), transaction building, EIP-712, EVM chain reader
  (JSON-RPC + Multicall3), Solana stack (sentinel ids 900/901/902), token store, Auth Pull
  (ERC-20 allowance surface), error model. NO Rain issuing API client (REMOVED 2026-09-18, PR F):
  fetching the collateral contract + admin withdrawal signature is the HOST's job (server-side,
  Api-Key off-device); the SDK only takes the results as `RainWithdrawAddresses` /
  `RainAdminSignature`. Token enrichment STAYS in the SDK as a public, wallet-agnostic
  `RainSdk.tokenMetadata(chainId:address:) -> TokenInfo?` (strict: nil when decimals unresolved,
  never the 18 default; Solana registry-only) over `TokenMetadataStore.resolvedTokenInfo`. The
  demo ships its own reference `RainApiClient`
  (`Example/.../Core/Services/RainApiClient.swift`). `RainApiEnvironment` is gone from the SDK;
  Auth Pull validation keys off `RainAuthPullConfig.kind` alone (`.custom` may use either
  environment's chains). RAIN_104 / RAIN_304 RETIRED, RAIN_303 = transactionPending only — never
  reuse the codes (Android still maps them). No wallet vendor SDKs. EVM ABI encoding + collateral contract reads go through
  Boilertalk Web3.swift ONLY — web3swift was REMOVED 2026-09-15 (abandoned upstream since 2025;
  its URLSession overload trick stopped compiling on new Xcode). Contract call outputs from
  Boilertalk decode under the ABI output NAME as key ("" for unnamed outputs, not "0").
- `RainTurnkey` (`rain-turnkey-ios`) — Turnkey adapter, BYO + managed modes (multi-chain
  EVM+Solana; `.multiChain`, `.biometricGate`). `RainPortal` (`rain-portal-ios`) — Portal MPC,
  EVM-only. `RainPrivy` (`rain-privy-ios`) — Privy embedded wallet (EIP-1193 custody, reads via
  Rain RPC). `RainWallet` (`rain-wallet-ios`) — Rain-branded provider: a wallet-neutral renaming
  layer over managed RainTurnkey (descriptor struct `RainProvider`, id `.rain`, embedded backend
  identity — `RainWalletConfig` carries behavior only, `RainProvider()` is zero-config); `@_spi(RainWallet) internal import RainTurnkey`
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
  `SolanaConverter`, `TokenMetadataStore.init`, `String.strippingHexPrefix`, `Base58`,
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
- PR B2 (DONE 2026-09-07; ids embedded 2026-09-11), `rain-wallet-ios` / `RainWallet`: renaming
  layer over managed RainTurnkey. DECISION 2026-09-11 (reverses the earlier host-supplied
  design): Rain's org id + auth config id are EMBEDDED in the module
  (`RainWalletBackend.organizationId` / `.authConfigId` — public identifiers, not secrets;
  abuse bounded by OTP rate limits). `RainWalletConfig(walletAddress:sessionPolicy:onSessionExpired:)`
  carries behavior only, and `RainProvider()` is zero-config (defaulted init). Descriptor struct
  `RainProvider`, id `ProviderId.rain`, neutral session surface (`RainWalletSessionState`,
  publisher, refreshSession). RainWallet @_exported imports RainCore only — NEVER RainTurnkey
  (no Turnkey symbol on a bare `import RainWallet`). Mutual exclusion guard in `RainSdk.build()`
  (.rain + .turnkey cannot both register — one TurnkeyContext per process). Demo app has a
  RainWallet provider option (email-only entry — no id fields; email OTP via the RainWallet
  methods, then the standard wallet screens), linking rain-wallet-ios.
- PR C (DONE 2026-09-11, merged as #36), key export — RainWallet-only, same SPI shape as
  managed auth.
  Public surface: `RainProvider.exportRecoveryPhrase()` (12-word BIP-39 phrase of the account's
  single seed) and `exportPrivateKey(_: RainWalletKeyAccount)` (`.ethereum` = 0x-prefixed 32-byte
  hex; `.solana` = plain Base58 of priv‖pub, no checksum — NOT the vendor's Base58Check, which
  Phantom rejects; built via CryptoKit ed25519 pubkey derivation + core's SPI Base58) — formats
  are a cross-platform contract with Android.
  Machinery: `TurnkeyContextProtocol.exportWalletMnemonic(walletId:)` (vendor `exportWallet`) and
  `exportAccountPrivateKey(address:encoding:)` (composed: generateP256KeyPair →
  client.exportWalletAccount → TurnkeyCrypto.decryptExportBundle, all on-device; no high-level
  per-account export at swift-sdk 4.0.0). Provider surface `exportMnemonic()` /
  `exportPrivateKey(family:)` is `@_spi(RainWallet)`; BYO mode throws invalidConfig. Legacy
  accounts (pre one-seed) can hold several wallets/seeds: the mnemonic export anchors on the
  wallet carrying the Ethereum account so phrase and exported ETH key always agree. The SDK
  never logs/persists exported values; gating (biometrics) and safe display are the host's job.
  RainTurnkey now also depends on the TurnkeyCrypto product. Demo: "Export keys" card on the
  Rain Wallet tab (tap-to-reveal, `.privacySensitive()`, value never logged; Copy uses a
  local-only pasteboard entry that self-expires after 60 s).
- PR D (DONE 2026-09-18, merged as #38), passkeys + SMS OTP for
  RainWallet — same SPI shape as managed auth. Public surface: `RainWalletContact`
  (.email/.phone) with `sendLoginCode(to:)` REPLACING `sendLoginCode(email:)` (clean break,
  v5 stance; confirmLoginCode unchanged — SMS reuses the whole OTP pipeline, vendor `.sms`);
  `signUpWithPasskey(anchor:)` / `loginWithPasskey(anchor:)` / `addPasskey(anchor:)` (add =
  raw client.createAuthenticators + TurnkeyPasskeys createPasskey ceremony on the live session,
  composed like export); contact-attach for passkey accounts:
  `sendContactVerificationCode(to:)` + `confirmContactVerification(_:)` (vendor verifyOtp →
  verificationToken → updateUserEmail/updateUserPhoneNumber so the contact lands VERIFIED and
  becomes a login method). Vendor facts (verified at 4.0.0): passkey flows accept a `sessionKey`
  param but IGNORE it — sessions always store under "com.turnkey.sdk.session" and storeSession
  throws keyAlreadyExists on an occupied key, so the controller needs a passkey session dance
  (pre-purge the default key only when it is NOT the live selection; explicit select after;
  purge the superseded per-attempt key; and REFUSE login/signup up front over a LIVE passkey
  session — the vendor stores the session LAST, so letting the ceremony run would mint an
  orphan passkey + for signup an orphan account before failing on the occupied key; an EXPIRED
  session under the selected default key is purged instead, waiting out the vendor's async
  state flip, and the ceremony proceeds); passkey signup merges our one-seed `customWallet`
  into CreateSubOrgParams (atomic provisioning holds); signup's stampLogin passes
  invalidateExisting: true but LOGIN's does not (single-active-session gap — flag upstream +
  Android). DECISION 2026-09-15 (reverses 2026-09-14's shared-Rain-domain plan): the passkey
  relying-party domain is PARTNER-SUPPLIED — `RainWalletConfig(passkeyDomain:)`, nil = passkeys
  off (invalidConfig). Each partner hosts their own AASA/assetlinks files and entitlement; Rain
  runs no shared passkey domain, and passkeys are per-partner (not portable across partner apps;
  the same account can hold passkeys from several domains). rpId still joins the one-shot vendor
  configure and is one-shot per launch. SMS is Turnkey-Enterprise
  (FEATURE_NAME_SMS_AUTH on Rain's org + allowed on the auth-proxy config; sandbox:
  +1 999-999-9999 / 000000 with alphanumeric=false, otpLength=6). Accounts NEVER merge
  (sub-org = account boundary): docs steer returning users to login/add-passkey, not signup;
  OPEN QUESTION to test + confirm with Turnkey: attaching a contact already owned by another
  sub-org (rejected, or ambiguous for contact-based login lookup?). Demo: email/phone toggle on
  the code flow + three passkey buttons (sign in / create / add). Everything here is a
  cross-platform contract with Android.
- PR E (IN PROGRESS 2026-09-17, branch volo/feature/handle-gas-sponsorship), gas sponsorship +
  fail-closed sends on chains Turnkey cannot broadcast on — a mirror of Android's WALL-31 and its
  follow-ups (TurnkeyBroadcastChains, minimal sponsored payloads with the
  gas-station nonce, sponsored Solana sends carrying the System Program key).
  Core: `Capability.gasSponsorship`; `RainSDKError.chainNotSupported(chainId:details:)` = RAIN_105;
  `WalletProvider` gains two hooks with default impls — `requireSendSupport(chainId:)` (no-op) and
  `sponsorsFees(chainId:)` (false). `RainSdkManager` gates `withdrawCollateral`,
  `prepareWithdrawal` (signing counts as sending) and `approveTokenAllowance` (after config
  validation, before the wallet) — estimates/reads are NEVER gated. DECISION 2026-09-17
  (diverges from Android, which quotes 0): fee estimates keep returning the REAL on-chain cost
  even when sponsored, so hosts can show the saving — flag to Android for parity. The Solana
  composers take `sponsoredFees` (skip the fee-lamport
  check and dry run — a zero-SOL wallet would false-fail — keep the rent check, and carry the
  System Program via `SolanaTransactionBuilder.extraReadonlyKeys`, which Turnkey's sponsored
  path can require).
  Turnkey: `TurnkeyBroadcastChains` (vendor's managed-broadcast list — EVM mainnets+testnets per
  docs.turnkey.com broadcasting page; Solana mainnet+devnet ONLY; also owns the get-balances
  chain list) — every send entry (EVM funnel `sendTransaction`, Solana funnel, both transfer
  entries) calls `requireSendSupport`. `TurnkeyConfig.sponsorGas` DEFAULTS TRUE (product
  decision: sponsorship is the product; on orgs without Gas Sponsorship enabled Turnkey rejects
  sponsored sends → pass false). Sponsored EVM body = minimal payload: no nonce/gas fields,
  `sponsor: true`, `gasStationNonce` fetched via `client.getNonces(gasStationNonce: true)` per
  send (Turnkey's one-tx-per-request guarantee needs it; nil → server-side fetch). Solana sends
  pass `sponsor`. `estimateTransactionFee` quotes the chain cost regardless. Capabilities via
  `TurnkeyWalletProviderAdapter.capabilities(sponsorGas:)`, shared by descriptor + wallet.
  `sponsorsFees` = sponsorGas && supportsSend (never sponsor an unsendable chain). RainWallet:
  `RainWalletConfig.sponsorGas` (default true), capabilities follow the backing provider.
  Tests construct adapters with `sponsorGas: false` to keep pinning the self-paid body (test
  helper default), and opt in explicitly for sponsored assertions. Known limitation (v0, both
  platforms): NO self-broadcast fallback — Avalanche (Rain's README example chain!), Celo,
  ZKsync are read-only through Turnkey until a signRawPayload + own-RPC path exists or Turnkey
  adds the chains.
- PR F (IN PROGRESS 2026-09-18, branch volo/refactor/move-rain-api-out-of-sdk), Rain API out of
  the SDK — see the RainCore bullet above. Deleted: `Services/RainApi/*`, `RainApiEnvironment`,
  `RainCollateralContract`, `RainSdk.fetchCollateralContracts/fetchCollateralContract/
  fetchAdminSignature/configureRainApi/isRainApiConfigured`, builder `rainApiEnvironment(_:)` /
  `rainApiCredentials(apiKey:userId:)`, error cases `rainApiNotConfigured` / `signatureNotReady` /
  `noCollateralContracts`, `RainAuthPullChains.supported(for:)/isSupported(chainId:in:)` (now an
  internal `supported(for: Kind)`). Android has NOT done this yet — iOS leads; flag for parity.
