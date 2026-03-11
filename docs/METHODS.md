# Method overview

Reference for Rain SDK public methods. Use `RainSDKManager()` and call these on the instance.

---

## portal

The initialized Portal instance. Use after `initializePortal`. Throws if SDK not initialized or using a mock.

- **Returns:** `Portal`
- **Throws:** `RainSDKError.sdkNotInitialized` when not initialized or when using a mock (e.g. in tests).

---

## initializePortal(portalSessionToken:networkConfigs:)

Initializes the SDK with a Portal session token and network configs. Use for full wallet flow (sign + send via Portal).

- **Returns:** (none, async)
- **Throws:** `RainSDKError` if initialization fails (e.g. invalid token, invalid RPC URLs).

| Parameter | Description |
|-----------|-------------|
| `portalSessionToken` | Valid Portal session token. |
| `networkConfigs` | Array of `NetworkConfig` (chain ID + RPC URL per network). |

---

## initialize(networkConfigs:)

Initializes the SDK with network configs only (no Portal). Use for wallet-agnostic mode (transaction building only).

- **Returns:** (none, async)
- **Throws:** `RainSDKError` if initialization fails (e.g. invalid RPC URLs).

| Parameter | Description |
|-----------|-------------|
| `networkConfigs` | Array of `NetworkConfig`. |

---

## buildEIP712Message(chainId:walletAddress:assetAddresses:amount:decimals:nonce:)

Builds EIP-712 typed data for the admin signature required for withdrawals.

- **Returns:** `(message: String, saltHex: String)` — serialized EIP-712 message and salt (hex string).
- **Throws:** `RainSDKError` if message construction fails or inputs are invalid.
- **Requires:** `initialize` or `initializePortal` first (no Portal required).

| Parameter | Description |
|-----------|-------------|
| `chainId` | Network chain ID (e.g. 1 for mainnet). |
| `walletAddress` | User wallet address (used as `user` in EIP-712). |
| `assetAddresses` | `EIP712AssetAddresses`: proxy, recipient, token addresses. |
| `amount` | Amount in token units (e.g. 100.0 for 100 tokens). |
| `decimals` | Token decimals (e.g. 18 for ETH, 6 for USDC). |
| `nonce` | Optional; if `nil`, SDK fetches from contract. |

---

## buildWithdrawTransactionData(chainId:assetAddresses:amount:decimals:expiresAt:salt:signatureData:adminSalt:adminSignature:)

Builds ABI-encoded withdraw calldata for the collateral proxy contract.

- **Returns:** Hex-encoded calldata string (e.g. `"0x..."`).
- **Throws:** `RainSDKError` if ABI encoding or validation fails.
- **Requires:** `initialize` or `initializePortal` first (no Portal required).

| Parameter | Description |
|-----------|-------------|
| `chainId` | Network chain ID. |
| `assetAddresses` | `WithdrawAssetAddresses`: contract, proxy, recipient, token. |
| `amount` | Amount in token units. |
| `decimals` | Token decimals. |
| `expiresAt` | Expiration Unix timestamp string. |
| `salt` | User salt data (32 bytes) for the withdrawal authorization. |
| `signatureData` | User/wallet signature from Rain API (`Data`, 65 bytes). |
| `adminSalt` | Admin salt from buildEIP712Message (`Data`, 32 bytes). |
| `adminSignature` | Admin signature authorizing the withdrawal (`Data`, 65 bytes). |

---

## composeTransactionParameters(walletAddress:contractAddress:transactionData:)

Composes Ethereum transaction parameters for submission (e.g. to `eth_sendTransaction`).

- **Returns:** `ETHTransactionParam`.
- **Throws:** (none)
- **Requires:** `initialize` or `initializePortal` first (no Portal required).

| Parameter | Description |
|-----------|-------------|
| `walletAddress` | Sender wallet address. |
| `contractAddress` | Target contract address. |
| `transactionData` | Hex-encoded calldata (e.g. from `buildWithdrawTransactionData`). |

---

## withdrawCollateral(chainId:assetAddresses:amount:decimals:salt:signature:expiresAt:nonce:)

Full withdrawal flow: build tx, sign via Portal, submit. Returns the transaction hash.

- **Returns:** Transaction hash string.
- **Throws:** `RainSDKError` if construction, signing, or submission fails.
- **Requires:** `initializePortal` first (Portal required).

| Parameter | Description |
|-----------|-------------|
| `chainId` | Target network chain ID. |
| `assetAddresses` | `WithdrawAssetAddresses`: contract, proxy, recipient, token. |
| `amount` | Amount in token units. |
| `decimals` | Token decimals. |
| `salt` | Salt for the user's withdrawal authorization (base64-encoded string, 32 bytes decoded). |
| `signature` | User/wallet signature from Rain API (hex string, 65 bytes). |
| `expiresAt` | Expiration Unix timestamp string (or ISO8601). |
| `nonce` | Optional; if `nil`, SDK resolves nonce. |

---

## getWalletAddress()

Returns the current wallet address from the wallet provider (e.g. EOA in `0x...` format).

- **Returns:** `String` — wallet address.
- **Throws:** `RainSDKError.walletUnavailable` when no wallet provider is set.
- **Requires:** `initializePortal` or `setWalletProvider` first.

---

## generateWalletAddressQRCode(dimension:backgroundColor:foregroundColor:)

Generates a square QR code image (PNG) encoding the current wallet address.

- **Returns:** `Data` — PNG image bytes.
- **Throws:** `RainSDKError` if wallet is unavailable or QR generation fails.
- **Requires:** Wallet provider set.

| Parameter | Description |
|-----------|-------------|
| `dimension` | Output width/height in pixels (default 256). |
| `backgroundColor` | Optional `CGColor`; default black. |
| `foregroundColor` | Optional `CGColor`; default white. |

---

## getTransactions(chainId:limit:offset:order:)

Fetches transaction history for the current wallet on the given network.

- **Returns:** `[WalletTransaction]` — list of transaction records (hash, from, to, value, blockNum, category, metadata, chainId, etc.).
- **Throws:** `RainSDKError.walletUnavailable` when no wallet provider is set.
- **Requires:** Wallet provider set (e.g. `initializePortal`).

| Parameter | Description |
|-----------|-------------|
| `chainId` | Network chain ID (e.g. 1 for Ethereum). |
| `limit` | Optional max number of transactions. |
| `offset` | Optional pagination offset. |
| `order` | Optional `WalletTransactionOrder` (`.ASC` or `.DESC`). |

---

## getNativeBalance(chainId:)

Fetches the native token balance (e.g. ETH) for the current wallet on the given network.

- **Returns:** `Double` — balance in human-readable form (e.g. 1.5 for 1.5 ETH).
- **Throws:** `RainSDKError.walletUnavailable` or RPC failure.
- **Requires:** Wallet provider set.

---

## getERC20Balance(chainId:tokenAddress:)

Fetches the ERC-20 token balance for a single token for the current wallet.

- **Returns:** `Double?` — balance in human-readable form, or `nil` if none.
- **Throws:** `RainSDKError` if wallet provider not set or request fails.
- **Requires:** Wallet provider set.

---

## getERC20Balances(chainId:)

Fetches all ERC-20 token balances for the current wallet on the given network.

- **Returns:** `[String: Double]` — token contract address → balance.
- **Throws:** `RainSDKError` if wallet provider not set or request fails.
- **Requires:** Wallet provider set.

---

## getBalances(chainId:)

Fetches all balances (native + ERC-20) for the current wallet. Native balance is under key `""`.

- **Returns:** `[String: Double]` — token address → balance; use `""` for native.
- **Throws:** `RainSDKError` if wallet provider not set or request fails.
- **Requires:** Wallet provider set.

---

## sendNativeToken(chainId:to:amount:)

Sends native tokens (e.g. ETH, AVAX) from the current wallet.

- **Returns:** Transaction hash string.
- **Throws:** `RainSDKError` if no wallet provider or send fails.
- **Requires:** Wallet provider set.

| Parameter | Description |
|-----------|-------------|
| `chainId` | Target network chain ID. |
| `to` | Recipient address. |
| `amount` | Amount in human-readable form (e.g. 1.5 for 1.5 ETH). |

---

## sendERC20Token(chainId:contractAddress:to:amount:decimals:)

Sends ERC-20 tokens from the current wallet.

- **Returns:** Transaction hash string.
- **Throws:** `RainSDKError` if SDK or wallet not initialized or send fails.
- **Requires:** Wallet provider and network configs (e.g. `initializePortal`).

| Parameter | Description |
|-----------|-------------|
| `chainId` | Target network chain ID. |
| `contractAddress` | ERC-20 token contract address. |
| `to` | Recipient address. |
| `amount` | Amount in human-readable form. |
| `decimals` | Token decimals (e.g. 18 for WETH, 6 for USDC). |

---

## estimateWithdrawalFee(chainId:addresses:amount:decimals:salt:signature:expiresAt:)

Estimates the total fee (gas cost) to execute a collateral withdrawal.

- **Returns:** Estimated fee in the chain's native token (e.g. ETH) as `Double`.
- **Throws:** `RainSDKError` if estimation fails (e.g. SDK not initialized, invalid response, network error).
- **Requires:** `initializePortal` first (Portal required).

| Parameter | Description |
|-----------|-------------|
| `chainId` | Target network chain ID. |
| `addresses` | `WithdrawAssetAddresses`: contract, proxy, recipient, token. |
| `amount` | Amount in token units. |
| `decimals` | Token decimals. |
| `salt` | Salt for the user's withdrawal authorization (base64-encoded string, 32 bytes decoded). |
| `signature` | User/wallet signature from Rain API (hex string, 65 bytes). |
| `expiresAt` | Expiration Unix timestamp string (or ISO8601). |

---

## Types used

| Type | Description |
|------|-------------|
| **NetworkConfig** | `chainId`, `rpcUrl`, optional `networkName`. |
| **EIP712AssetAddresses** | `proxyAddress`, `recipientAddress`, `tokenAddress`. |
| **WithdrawAssetAddresses** | `contractAddress`, `proxyAddress`, `recipientAddress`, `tokenAddress`. |
| **ETHTransactionParam** | Composed transaction payload for submission. |
| **WalletTransaction** | Transaction record: `hash`, `from`, `to`, `value`, `blockNum`, `category`, `metadata`, `chainId`, etc. Returned by `getTransactions`. |
| **WalletTransactionOrder** | Sort order for transaction history: `.ASC`, `.DESC`. Used in `getTransactions(..., order:)`. |

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
| RAIN_403 | `walletUnavailable` | No wallet address from Portal (e.g. user has not connected or created a wallet). |
| RAIN_501 | `providerError(underlying:)` | Portal or provider error. |
| RAIN_502 | `internalLogicError(details:)` | EIP-712 or internal processing error. |
