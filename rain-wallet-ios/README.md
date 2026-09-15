# RainWallet

The Rain-branded wallet provider for the modular Rain iOS SDK.

The wallet backend identity is embedded in the SDK — hosts configure nothing. The SDK owns the
whole wallet lifecycle: authentication (email one-time codes), wallet provisioning (EVM + Solana
on first login), session management, and the full `RainClient` surface. Linking
`rain-wallet-ios` is all an app needs: `RainCore` comes transitively (and is re-exported, so
`import RainWallet` surfaces the full SDK).

```swift
import RainWallet   // re-exports RainCore

let provider = RainProvider()   // optionally RainProvider(RainWalletConfig(onSessionExpired:...))

// Reuse a restored session, or run the login-code flow (email or SMS):
await provider.awaitSessionRestore()
if !provider.hasActiveSession() {
    try await provider.sendLoginCode(to: .email("user@example.com"))  // or .phone("+1555...")
    try await provider.confirmLoginCode(code) // signup-or-login + EVM/Solana wallet provisioning
    // ...or passkeys: loginWithPasskey(anchor:) / signUpWithPasskey(anchor:)
}

let rain = try RainSdk.builder()
    .rpcEndpoints([43114: "https://…"])
    .register(provider)
    .build()
let client = try await rain.provider(.rain)
```

`authState` (and its publisher `authStates`) reports `.loading` / `.authenticated` /
`.unauthenticated`; `sessionState` / `currentSessionState()` expose the session over time
(`RainWalletSessionState`), `refreshSession()` forces a refresh, `logout()` clears the stored
session, and `close()` stops the passive session watcher when discarding a provider.
Configure expiry/refresh/retry behavior via `RainWalletConfig.sessionPolicy`
(`RainWalletSessionPolicy`) and react to unrecoverable expiry via `onSessionExpired`.

## Passkeys and login contacts

`signUpWithPasskey(anchor:)` creates a NEW account (fresh wallet — returning users must use
`loginWithPasskey(anchor:)` or a login code, or they end up with a second, empty account);
`addPasskey(anchor:)` registers a passkey on the current account so the next login can skip the
code. Passkeys use YOUR domain: set `RainWalletConfig(passkeyDomain:)` to a web domain you
control, serve `/.well-known/apple-app-site-association` on it listing your app under
`webcredentials`, and add the `webcredentials:<domain>` Associated Domains entitlement. Without
a configured domain the passkey methods throw `invalidConfig`. The domain is permanent — your
users' passkeys are bound to it — and passkeys from one domain don't work in apps on another.
A passkey-created account can attach a verified email or phone with
`sendContactVerificationCode(to:)` + `confirmContactVerification(_:)`, after which that contact
is a login method too. SMS login requires SMS auth enabled on the wallet backend. Accounts are
never merged: attaching a contact adds a login method to THIS account; it never moves wallets.

## Key export

The account has ONE wallet seed covering both chain families, so a single recovery phrase
restores everything. With an active session:

```swift
let phrase = try await provider.exportRecoveryPhrase()          // 12 words (BIP-39)
let ethKey = try await provider.exportPrivateKey(.ethereum)     // 0x-prefixed 32-byte hex
let solKey = try await provider.exportPrivateKey(.solana)       // Base58, importable by Solana wallets
```

Decryption happens on-device and the SDK never logs or persists the values. Everything after the
return is the app's responsibility: gate the call (e.g. behind biometrics), display the secret
without screenshots/screen recording where possible, and keep it off the pasteboard. The Android
SDK returns the same formats.

Notes:

- The wallet-backend configuration is one-shot per app launch.
- The Rain wallet provider cannot be registered alongside the Turnkey provider in one app
  (`RainSdk.build()` rejects the combination); they share one process-wide wallet backend.
- Multi-chain: the same provider serves EVM chains and Solana clusters
  (`RainChain.solanaMainnet` / `.solanaDevnet` / `.solanaTestnet`). Advertised capabilities:
  `.multiChain`, `.biometricGate`.
