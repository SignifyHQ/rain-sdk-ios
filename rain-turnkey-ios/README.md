# RainTurnkey

The [Turnkey](https://www.turnkey.com) adapter for the modular Rain iOS SDK.

Depends on `RainCore` + Turnkey's Swift SDK (`TurnkeySwift`, `TurnkeyHttp`, `TurnkeyTypes`).
Linking `rain-turnkey-ios` is all a Turnkey app needs — `RainCore` comes transitively (and is
re-exported, so `import RainTurnkey` surfaces the full SDK), and Portal's / Privy's vendor SDKs
never enter the dependency graph.

Turnkey authentication happens **outside** Rain: the host app drives Turnkey's Swift SDK
(auth proxy / passkeys / OAuth / OTP), then hands the authenticated `TurnkeyContext` to Rain:

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
`TurnkeyWalletProviderAdapter` (mapping Turnkey onto `RainWalletProvider`), the session
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
