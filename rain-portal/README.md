# RainPortal

The [Portal](https://portalhq.io) MPC adapter for the modular Rain iOS SDK.

Depends on `RainCore` + `PortalSwift`. Linking `RainPortal` is all a Portal-only app needs —
`RainCore` comes transitively, and Turnkey's / Privy's vendor SDKs never enter the dependency graph.

```swift
import RainCore
import RainPortal

let rain = try RainSdk.builder()
    .rpcEndpoints([43114: "https://avalanche-c-chain-rpc.publicnode.com"])
    .register(PortalProvider(PortalConfig(sessionToken: "<your-portal-session-token>")))
    .build()

let client = try await rain.provider(.portal)
```

This module owns everything Portal-specific: the `PortalProvider` descriptor, the
`PortalWalletProviderAdapter` (mapping Portal onto `RainWalletProvider`), Portal ↔ Rain model
mappers, and Portal error mapping (registered with `RainCore` at runtime so core stays Portal-free).

Advertised capabilities: `.export`, `.recovery`.
