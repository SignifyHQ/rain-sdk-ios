# Method overview

Reference for Rain SDK public methods. Use `RainSDKManager()` and call these on the instance.

---

## portal

The initialized Portal instance. Use after `initializePortal`. Throws if SDK not initialized or using a mock.

- **Returns:** `Portal`
- **Throws:** `RainSDKError.sdkNotInitialized` when not initialized or when using a mock (e.g. in tests).

---

## turnkey

The initialized Turnkey context. Use after `initializeTurnkey`. Throws if SDK not initialized or using a mock.

- **Returns:** `TurnkeyContext`
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

## initializeTurnkey(turnkey:networkConfigs:walletAddress:)

Initializes the SDK with an authenticated Turnkey context and network configs. Use for full wallet flow (sign + send via Turnkey).

- **Returns:** (none, async)
- **Throws:** `RainSDKError` if initialization fails (e.g. invalid RPC URLs, no usable EVM wallet).

| Parameter | Description |
|-----------|-------------|
| `turnkey` | Authenticated `TurnkeyContext` from the official Turnkey Swift SDK. |
| `networkConfigs` | Array of `NetworkConfig` (chain ID + RPC URL per network). |
| `walletAddress` | Optional explicit EVM address override. If omitted, Rain uses the first available Ethereum account in the Turnkey context. |

Turnkey authentication happens outside Rain. Typical setup uses Turnkey's Swift SDK with auth proxy middleware and passkeys:

- Proxy middleware: `https://docs.turnkey.com/sdks/swift/proxy-middleware`
- Passkeys: `https://docs.turnkey.com/sdks/swift/register-passkey`

---

## initialize(networkConfigs:)

Initializes the SDK with network configs only (no wallet provider). Use for wallet-agnostic mode (transaction building only).

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
- **Requires:** `initialize`, `initializePortal`, or `initializeTurnkey` first.

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
- **Requires:** `initialize`, `initializePortal`, or `initializeTurnkey` first.

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
- **Requires:** `initialize`, `initializePortal`, or `initializeTurnkey` first.

| Parameter | Description |
|-----------|-------------|
| `walletAddress` | Sender wallet address. |
| `contractAddress` | Target contract address. |
| `transactionData` | Hex-encoded calldata (e.g. from `buildWithdrawTransactionData`). |

---

## withdrawCollateral(chainId:assetAddresses:amount:decimals:salt:signature:expiresAt:nonce:)

Full withdrawal flow: build tx, sign via the active wallet provider, submit. Returns the transaction hash.

- **Returns:** Transaction hash string.
- **Throws:** `RainSDKError` if construction, signing, or submission fails.
- **Requires:** A wallet provider with EIP-712 signing and transaction submission support (for example `initializePortal` or `initializeTurnkey`).

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
- **Requires:** `initializePortal`, `initializeTurnkey`, or `setWalletProvider` first.

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
- **Requires:** Wallet provider set (e.g. `initializePortal` or `initializeTurnkey`).

| Parameter | Description |
|-----------|-------------|
| `chainId` | Network chain ID (e.g. 1 for Ethereum). |
| `limit` | Optional max number of transactions. |
| `offset` | Optional pagination offset. |
| `order` | Optional `WalletTransactionOrder` (`.ASC` or `.DESC`). |

---

## getBalance(chainId:token:)

Fetches a single balance — native or a specific contract token — for the current wallet.

- **Parameters:** `token` is `.native` or `.contract(address:)`.
- **Returns:** `Balance` — exact `rawAmount` (`BigUInt`) plus `decimals`, `symbol`, `name`, and `decimalAmount` / `formatted` accessors.
- **Throws:** `RainSDKError.walletUnavailable` or RPC failure.
- **Requires:** Wallet provider set.

---

## getBalances(chainId:)

Fetches all non-zero balances for the current wallet on the given network. The native balance is always included.

- **Returns:** `[Balance]` — one entry per held token plus native.
- **Throws:** `RainSDKError` if wallet provider not set or request fails.
- **Requires:** Wallet provider set.

---

## getAllBalances()

Fetches balances across every configured chain in parallel, flattened into one list. Each `Balance` carries its own `chainId`. A chain that fails contributes no entries rather than failing the whole call.

- **Returns:** `[Balance]` — merged across all configured chains.
- **Throws:** `RainSDKError.walletUnavailable`.
- **Requires:** Wallet provider set.

---

## registerTokens(_:)

Registers additional `TokenInfo` so their metadata resolves from the store without an on-chain `decimals()` / `symbol()` lookup. Retained across re-initialization; cleared by `reset()`.

- **Parameters:** `tokens` — `[TokenInfo]` to add (replaces any existing entry with the same chain + address).
- **Returns:** `Void`.

---

## sendNativeToken(chainId:to:amount:)

Sends native tokens (e.g. ETH, AVAX, SOL) from the current wallet.

- **Returns:** `RainTokenTransferResult` carrying the transaction hash (EVM) or signature (Solana).
- **Throws:** `RainSDKError` if no wallet provider or send fails.
- **Requires:** Wallet provider set.

| Parameter | Description |
|-----------|-------------|
| `chainId` | Target network chain ID. EVM chain ID or Solana sentinel (101/102/103). |
| `to` | Recipient address (hex on EVM, base58 on Solana). |
| `amount` | Amount in human-readable form (e.g. 1.5 for 1.5 ETH / 0.5 for 0.5 SOL). |

---

## sendToken(chainId:contractAddress:to:amount:decimals:)

Sends ERC-20 tokens (EVM chains) from the current wallet. Routed by `chainId`.

- **Returns:** `RainTokenTransferResult` carrying the transaction hash (EVM) or signature (Solana).
- **Throws:** `RainSDKError` if SDK or wallet not initialized or send fails.
- **Throws on Solana chains:** SPL token transfers are not yet implemented; calling this
  method with a Solana `chainId` (sentinel 101–103) throws `RainSDKError.internalLogicError`.
- **Requires:** Wallet provider and network configs (e.g. `initializePortal` or `initializeTurnkey`).

| Parameter | Description |
|-----------|-------------|
| `chainId` | Target network chain ID. EVM chain ID. (Solana SPL transfers not yet implemented — see note above.) |
| `contractAddress` | ERC-20 token contract address. |
| `to` | Recipient address. |
| `amount` | Amount in human-readable form. |
| `decimals` | Token decimals (e.g. 18 for WETH, 6 for USDC). |

---

## estimateWithdrawalFee(chainId:addresses:amount:decimals:salt:signature:expiresAt:)

Estimates the total fee (gas cost) to execute a collateral withdrawal.

- **Returns:** Estimated fee in the chain's native token (e.g. ETH) as `Double`.
- **Throws:** `RainSDKError` if estimation fails (e.g. SDK not initialized, invalid response, network error).
- **Requires:** A wallet provider with EIP-712 signing and fee estimation support (for example `initializePortal` or `initializeTurnkey`).

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
| **RainTokenTransferResult** | `transactionHash` (String) — on-chain hash (EVM) or signature (Solana). Returned by `sendNativeToken` and `sendToken`. |

---

## Errors

All async methods can throw `RainSDKError`. Use `errorCode` for programmatic handling.

| Code | Case | Meaning |
|------|------|--------|
| RAIN_101 | `sdkNotInitialized` | Method called before `initialize`, `initializePortal`, or `initializeTurnkey`, or no wallet provider is installed. |
| RAIN_102 | `invalidConfig(chainId:rpcUrl:)` | Invalid RPC URL or chain ID. |
| RAIN_103 | `invalidRpcUrl(_:)` | RPC URL could not be parsed as a valid URL. |
| RAIN_201 | `tokenExpired` | Wallet provider session token expired or invalid. |
| RAIN_202 | `unauthorized` | Invalid or missing token / permissions. |
| RAIN_301 | `networkError(underlying:)` | Network/connectivity failure. |
| RAIN_401 | `userRejected` | User cancelled the signing request in the wallet. |
| RAIN_402 | `insufficientFunds(required:available:)` | Balance too low for amount or gas. |
| RAIN_403 | `transactionSimulationFailed(underlying:)` | Transaction simulation (preflight) failed before submission, e.g. a contract revert. |
| RAIN_404 | `walletUnavailable` | No wallet address from the wallet provider (e.g. user has not connected or created a wallet). |
| RAIN_405 | `withdrawalRevertedByNetwork` | Withdrawal reverted on-chain (e.g. duplicate withdrawal in short window / already-used signature). |
| RAIN_501 | `providerError(underlying:)` | Wallet provider error (Portal or Turnkey). |
| RAIN_502 | `internalLogicError(details:)` | EIP-712, configuration, or internal processing error. |
