# Method overview

Reference for Rain SDK public methods. Use `RainSDKManager()` and call these on the instance.

---

## Property

| Method | Description |
|--------|-------------|
| `portal: Portal` (throws) | The initialized Portal instance. Use after `initializePortal`. Throws if SDK not initialized or using a mock. |

---

## Initialization

| Method | Description |
|--------|-------------|
| `initializePortal(portalSessionToken:networkConfigs:)` | Initializes with a Portal session token and network configs. Use for full wallet flow (sign + send via Portal). |
| `initialize(networkConfigs:)` | Initializes with network configs only (no Portal). Use for wallet-agnostic mode (transaction building only). |

**Parameters**

| Method | Parameter | Description |
|--------|------------|-------------|
| `initializePortal` | `portalSessionToken` | Valid Portal session token. |
| `initializePortal` | `networkConfigs` | Array of `NetworkConfig` (chain ID + RPC URL per network). |
| `initialize` | `networkConfigs` | Array of `NetworkConfig`. |

---

## Transaction building (no Portal required)

| Method | Description |
|--------|-------------|
| `buildEIP712Message(chainId:walletAddress:assetAddresses:amount:decimals:nonce:)` | Builds EIP-712 typed data for the admin signature. Returns `(message: String, saltHex: String)`. |
| `buildWithdrawTransactionData(chainId:assetAddresses:amount:decimals:expiresAt:signatureData:adminSalt:adminSignature:)` | Builds ABI-encoded withdraw calldata. Returns hex string (e.g. `"0x..."`). |
| `composeTransactionParameters(walletAddress:contractAddress:transactionData:)` | Composes `ETHTransactionParam` for submission (e.g. to `eth_sendTransaction`). |

**Parameters**

| Method | Parameter | Description |
|--------|------------|-------------|
| `buildEIP712Message` | `chainId` | Network chain ID (e.g. 1 for mainnet). |
| `buildEIP712Message` | `walletAddress` | User wallet address (used as `user` in EIP-712). |
| `buildEIP712Message` | `assetAddresses` | `EIP712AssetAddresses`: proxy, recipient, token addresses. |
| `buildEIP712Message` | `amount` | Amount in token units (e.g. 100.0 for 100 tokens). |
| `buildEIP712Message` | `decimals` | Token decimals (e.g. 18 for ETH, 6 for USDC). |
| `buildEIP712Message` | `nonce` | Optional; if `nil`, SDK fetches from contract. |
| `buildWithdrawTransactionData` | `chainId` | Network chain ID. |
| `buildWithdrawTransactionData` | `assetAddresses` | `WithdrawAssetAddresses`: contract, proxy, recipient, token. |
| `buildWithdrawTransactionData` | `amount` | Amount in token units. |
| `buildWithdrawTransactionData` | `decimals` | Token decimals. |
| `buildWithdrawTransactionData` | `expiresAt` | Expiration Unix timestamp string. |
| `buildWithdrawTransactionData` | `signatureData` | User/wallet signature from Rain API (`Data`). |
| `buildWithdrawTransactionData` | `adminSalt` | Salt used when building the admin signature (same as from `buildEIP712Message`). |
| `buildWithdrawTransactionData` | `adminSignature` | Admin signature authorizing the withdrawal (`Data`). |
| `composeTransactionParameters` | `walletAddress` | Sender wallet address. |
| `composeTransactionParameters` | `contractAddress` | Target contract address. |
| `composeTransactionParameters` | `transactionData` | Hex-encoded calldata (e.g. from `buildWithdrawTransactionData`). |

---

## Withdrawal (Portal required)

| Method | Description |
|--------|-------------|
| `withdrawCollateral(chainId:assetAddresses:amount:decimals:signature:expiresAt:nonce:)` | Full flow: build tx, sign via Portal, submit. Returns transaction hash. Requires `initializePortal` first. |

**Parameters**

| Parameter | Description |
|-----------|-------------|
| `chainId` | Target network chain ID. |
| `assetAddresses` | `WithdrawAssetAddresses`: contract, proxy, recipient, token. |
| `amount` | Amount in token units. |
| `decimals` | Token decimals. |
| `signature` | User/wallet signature from Rain API (base64 string). |
| `expiresAt` | Expiration Unix timestamp string (or ISO8601). |
| `nonce` | Optional; if `nil`, SDK resolves nonce. |

---

## Types used

| Type | Description |
|------|-------------|
| **NetworkConfig** | `chainId`, `rpcUrl`, optional `networkName`. |
| **EIP712AssetAddresses** | `proxyAddress`, `recipientAddress`, `tokenAddress`. |
| **WithdrawAssetAddresses** | `contractAddress`, `proxyAddress`, `recipientAddress`, `tokenAddress`. |
| **ETHTransactionParam** | Composed transaction payload for submission. |

---

## Errors

All async methods can throw `RainSDKError`. Use `errorCode` for programmatic handling.

| Code | Case | Meaning |
|------|------|--------|
| RAIN_101 | `sdkNotInitialized` | Method called before `initialize` or `initializePortal`. |
| RAIN_102 | `invalidConfig(chainId:rpcUrl:)` | Invalid RPC URL or chain ID. |
| RAIN_201 | `tokenExpired(token:)` | Portal session token expired or invalid. |
| RAIN_202 | `unauthorized` | Invalid or missing token / permissions. |
| RAIN_301 | `networkError(underlying:)` | Network/connectivity failure. |
| RAIN_401 | `userRejected` | User cancelled the signing request in the wallet. |
| RAIN_402 | `insufficientFunds(required:available:)` | Balance too low for amount or gas. |
| RAIN_501 | `providerError(underlying:)` | Portal or provider error. |
| RAIN_502 | `internalLogicError(details:)` | EIP-712 or internal processing error. |
