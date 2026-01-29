# Method overview

Concise reference for Rain SDK public methods. Use `RainSDKManager()` and call these on the instance.

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

---

## Transaction building (no Portal required)

| Method | Description |
|--------|-------------|
| `buildEIP712Message(chainId:walletAddress:assetAddresses:amount:decimals:nonce:)` | Builds EIP-712 typed data for the admin signature. Returns `(message: String, saltHex: String)`. |
| `buildWithdrawTransactionData(chainId:assetAddresses:amount:decimals:expiresAt:signatureData:adminSalt:adminSignature:)` | Builds ABI-encoded withdraw calldata. Returns hex string (e.g. `"0x..."`). |
| `composeTransactionParameters(walletAddress:contractAddress:transactionData:)` | Composes `ETHTransactionParam` for submission (e.g. to `eth_sendTransaction`). |

---

## Withdrawal (Portal required)

| Method | Description |
|--------|-------------|
| `withdrawCollateral(chainId:assetAddresses:amount:decimals:signature:expiresAt:nonce:)` | Full flow: build tx, sign via Portal, submit. Returns transaction hash. Requires `initializePortal` first. |

---

## Types used

- **NetworkConfig** — `chainId`, `rpcUrl`, optional `networkName`
- **EIP712AssetAddresses** — `proxyAddress`, `recipientAddress`, `tokenAddress`
- **WithdrawAssetAddresses** — `contractAddress`, `proxyAddress`, `recipientAddress`, `tokenAddress`
- **ETHTransactionParam** — Composed transaction payload

All async methods throw `RainSDKError` on failure.
