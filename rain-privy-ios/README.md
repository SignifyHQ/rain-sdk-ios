# RainPrivy

The [Privy](https://www.privy.io) embedded-key adapter for the modular Rain iOS SDK.

Depends on `RainCore` + the Privy iOS SDK (`Privy`, binary xcframework). Linking `RainPrivy` is all
a Privy-only app needs: `RainCore` comes transitively, and Portal's / Turnkey's vendor SDKs never
enter the dependency graph.

Privy authentication and embedded-wallet provisioning happen outside Rain: initialize the `Privy`
singleton at app start, log the user in, ensure an embedded Ethereum wallet exists
(`user.createEthereumWallet()`), then hand the singleton to Rain.

```swift
import RainCore
import RainPrivy

// Host app: authenticate with the Privy iOS SDK and ensure an embedded Ethereum wallet exists.

let rain = try RainSdk.builder()
    .rpcEndpoints([43114: "https://avalanche-c-chain-rpc.publicnode.com"])
    .register(PrivyProvider(PrivyConfig(privy: privy)))
    .build()

let client = try await rain.provider(.privy)
```

This module owns everything Privy-specific: the `PrivyProvider` descriptor, the
`PrivyWalletProvider` (mapping Privy onto `RainWalletProvider`), the Privy RPC client used for
balance / fee reads against Rain's configured endpoints, and Privy error mapping (registered with
`RainCore` at runtime so core stays Privy-free).

Custody (signing, broadcasting) routes through Privy's EIP-1193 embedded wallet; transaction
history comes from Privy's indexer on the chains it supports (unsupported chains return an empty
list). Resolving `rain.provider(.privy)` probes for an embedded Ethereum wallet and throws
`RainSDKError.walletUnavailable` if none is available.

Advertised capabilities: `.export`, `.recovery`, `.multiChain`.
