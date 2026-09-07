# RainTurnkey

The [Turnkey](https://www.turnkey.com) adapter for the modular Rain iOS SDK.

Depends on `RainCore` + Turnkey's Swift SDK (`TurnkeySwift`, `TurnkeyHttp`, `TurnkeyTypes`).
Linking `rain-turnkey-ios` is all a Turnkey app needs — `RainCore` comes transitively (and is
re-exported, so `import RainTurnkey` surfaces the full SDK), and Portal's / Privy's vendor SDKs
never enter the dependency graph.

The provider has two modes:

**Managed (recommended)** — the SDK owns Turnkey authentication. Configure with your Turnkey
organization id and auth-proxy config id, then run the email-OTP flow on the provider itself:

```swift
import RainTurnkey   // re-exports RainCore

let provider = TurnkeyProvider(
    TurnkeyConfig(organizationId: "<org-id>", authProxyConfigId: "<auth-proxy-config-id>")
)

// Reuse a restored session, or run the OTP flow:
await provider.awaitSessionRestore()
if !provider.hasActiveSession() {
    try await provider.sendLoginCode(email: "user@example.com")
    try await provider.confirmLoginCode(code) // signup-or-login + EVM/Solana wallet provisioning
}

let rain = try RainSdk.builder()
    .rpcEndpoints([43114: "https://…"])
    .register(provider)
    .build()
let client = try await rain.provider(.turnkey)
```

`authState` (and its publisher `authStates`) reports `.loading` / `.authenticated` /
`.unauthenticated`; `logout()` clears the stored session. The underlying Turnkey configuration is
one-shot per app launch — changing the ids requires a relaunch.

**Bring-your-own** — the host drives Turnkey's Swift SDK itself (auth proxy / passkeys / OAuth /
OTP) and hands the authenticated `TurnkeyContext` to Rain; auth methods on the provider throw
`invalidConfig` in this mode:

```swift
import RainTurnkey   // re-exports RainCore

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

This module owns everything Turnkey-specific: the `TurnkeyProvider` descriptor, the
`TurnkeyWalletProviderAdapter` (mapping Turnkey onto `WalletProvider`), the session
coordinator and `TurnkeySessionPolicy` (expiry checks, proactive refresh, refresh-on-401,
transient retry, the `onSessionExpired` hook), the indexed transaction-history client, and
Turnkey error mapping (registered with `RainCore` at runtime so core stays Turnkey-free).

Turnkey is a multi-chain signer: the same provider serves EVM chains and Solana clusters
(`RainChain.solanaMainnet` / `.solanaDevnet` / `.solanaTestnet`), resolving the appropriate
account per chain family.

Advertised capabilities: `.multiChain`, `.biometricGate`.

## Session expiry and retry

`TurnkeyProvider` exposes the session as Rain sees it: `sessionState` (a publisher that emits on
every auth/session change and when an active session passes its expiry), `currentSessionState()`,
`refreshSession()` (force-refresh; throws `RainSDKError.tokenExpired` when the session cannot be
refreshed), and `close()` (stops the passive watcher when discarding the provider). Configure the
behavior via `TurnkeyConfig.sessionPolicy` and react to unrecoverable expiry via
`TurnkeyConfig.onSessionExpired`.

For the full integration guide — architecture split, auth flows, Solana notes — see
[docs/TURNKEY_SUPPORT.md](../docs/TURNKEY_SUPPORT.md).
