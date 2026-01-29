# Rain SDK iOS

[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)](#installation)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-not--supported-lightgrey)](#installation)
[![Carthage](https://img.shields.io/badge/Carthage-not--supported-lightgrey)](#installation)

iOS SDK that integrates [Portal](https://portalhq.io) wallet with Rain collateral withdrawal: build EIP-712 messages, compose withdrawal transactions, sign and submit via Portal, and estimate fees.

## Features

- **Portal wallet integration** — Initialize with a Portal session token and network configs; use the connected wallet for signing and sending transactions.
- **Wallet-agnostic mode** — Initialize with network configs only (no Portal) to use transaction-building APIs (EIP-712 message, withdraw calldata, composed params) with your own wallet or backend.
- **EIP-712 message building** — Build typed data for admin signature required by the collateral contract.
- **Withdrawal transaction building** — Build ABI-encoded withdraw calldata and compose `ETHTransactionParam` for submission.
- **Full withdrawal flow** — `withdrawCollateral` builds the transaction, signs via Portal, and submits; returns the transaction hash.
- **Fee estimation** — `estimateWithdrawalFee` returns the estimated gas cost in the chain’s native token (e.g. ETH).

## Installation

### Swift Package Manager

Add the package to your project (Xcode: **File → Add Package Dependencies**):

```
https://github.com/<your-org>/rain-sdk-ios
```

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/<your-org>/rain-sdk-ios", from: "1.0.0")
]
```

Then add the **RainSDK** product to your target.

## Requirements

- iOS 17.0+
- Swift 6.1+
- Xcode 15.0+

## Usage

### 1. Initialize with Portal (full wallet flow)

Use this when you want the SDK to use Portal for signing and sending transactions.

```swift
import RainSDK

let manager = RainSDKManager()

let networkConfigs = [
    NetworkConfig(chainId: 1, rpcUrl: "https://mainnet.infura.io/v3/YOUR_KEY"),
    NetworkConfig(chainId: 137, rpcUrl: "https://polygon-rpc.com")
]

try await manager.initializePortal(
    portalSessionToken: "<your-portal-session-token>",
    networkConfigs: networkConfigs
)

// Access the Portal instance when needed (e.g. for UI)
let portal = try manager.portal
```

### 2. Initialize without Portal (wallet-agnostic)

Use this when you only need transaction building (EIP-712 message, calldata, composed params) and will sign/submit elsewhere.

```swift
let manager = RainSDKManager()

try await manager.initialize(networkConfigs: networkConfigs)

// buildEIP712Message, buildWithdrawTransactionData, composeTransactionParameters
// are available; withdrawCollateral and estimateWithdrawalFee require Portal.
```

## License

See the [LICENSE](LICENSE) file for details.
