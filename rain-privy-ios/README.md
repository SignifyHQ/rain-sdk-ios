# RainPrivy

The [Privy](https://www.privy.io) embedded-key adapter for the modular Rain iOS SDK — **skeleton**.

This module exists to prove the modular architecture's thesis: a net-new provider arrives as its own
artifact (`RainPrivy`) with its own vendor dependency, and costs existing Portal / Turnkey clients
nothing. The `PrivyProvider` descriptor registers and advertises its capabilities, but the wallet
operations throw until the Privy SDK is wired.

```swift
import RainCore
import RainPrivy

let rain = try RainSdk.builder()
    .rpcEndpoints([43114: "https://avalanche-c-chain-rpc.publicnode.com"])
    .register(PrivyProvider(PrivyConfig(appId: "<your-privy-app-id>")))
    .build()

// let client = try await rain.provider(.privy)  // operations currently throw (not implemented)
```

Advertised capabilities: `.export`, `.recovery`.

When the Privy embedded-wallet SDK is integrated, it will be added as a dependency of this package
only, and `PrivyWalletProvider` will implement the port.
