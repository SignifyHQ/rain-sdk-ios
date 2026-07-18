# RainCore

The vendor-free core of the modular Rain iOS SDK — the "one core" in *one core, many providers*.

Contains:

- The **`RainWalletProvider`** port (the capability the SDK needs from any wallet).
- The **`RainProvider`** descriptor + **`RainSdk`** builder/registry (`RainSdk.builder().register(…).build()`, resolve via `provider(_:)` / `first { }`).
- The **`Capability`** model and **`ProviderId`**.
- All Rain domain logic — EIP-712 message building, collateral withdraw flow, transaction orchestration, chain readers, token metadata store.
- The **Turnkey adapter** (`TurnkeyProvider` / `TurnkeyConfig`), bundled here for now. It will graduate to a standalone `rain-turnkey` module later; the seam is identical to an out-of-core adapter.

`RainCore` has **no Portal or Privy dependency**. Its only wallet-vendor dependency is Turnkey.

```swift
import RainCore

let rain = try RainSdk.builder()
    .rpcEndpoints([43114: "https://avalanche-c-chain-rpc.publicnode.com"])
    .register(TurnkeyProvider(TurnkeyConfig(turnkey: turnkeyContext)))
    .build()

let client = try await rain.provider(.turnkey)
let address = try await client.getWalletAddress()
```

To add Portal, depend on `RainPortal` (which pulls `RainCore` transitively). To add Privy, depend on `RainPrivy`.
