# RainWallet

The Rain-branded wallet provider for the modular Rain iOS SDK.

Rain issues each partner an **organization id** and an **auth configuration id**; with those, the
SDK owns the whole wallet lifecycle — authentication (email one-time codes), wallet provisioning
(EVM + Solana on first login), session management, and the full `RainClient` surface. Linking
`rain-wallet-ios` is all an app needs: `RainCore` comes transitively (and is re-exported, so
`import RainWallet` surfaces the full SDK).

```swift
import RainWallet   // re-exports RainCore

let provider = RainProvider(
    RainWalletConfig(organizationId: "<org-id>", authConfigId: "<auth-config-id>")
)

// Reuse a restored session, or run the login-code flow:
await provider.awaitSessionRestore()
if !provider.hasActiveSession() {
    try await provider.sendLoginCode(email: "user@example.com")
    try await provider.confirmLoginCode(code) // signup-or-login + EVM/Solana wallet provisioning
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

Notes:

- The wallet-backend configuration is one-shot per app launch — changing the ids requires a
  relaunch.
- The Rain wallet provider cannot be registered alongside the Turnkey provider in one app
  (`RainSdk.build()` rejects the combination); they share one process-wide wallet backend.
- Multi-chain: the same provider serves EVM chains and Solana clusters
  (`RainChain.solanaMainnet` / `.solanaDevnet` / `.solanaTestnet`). Advertised capabilities:
  `.multiChain`, `.biometricGate`.
