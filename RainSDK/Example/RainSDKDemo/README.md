# Rain SDK Demo App

A SwiftUI sample app that demonstrates all public features of the **Rain SDK**. Use it to try SDK initialization, EIP-712 message building, withdraw transaction building, and full Portal withdrawal flows.

---

## Requirements

- Xcode 15+ (Swift 5.9+)
- iOS 16+
- Rain SDK added as a dependency (Swift Package or local)

---

## How to run

1. Open **RainSDK** in Xcode (e.g. `RainSDK/Package.swift` or the workspace).
2. Select the **RainSDKDemo** app scheme.
3. Choose a simulator or device and run (⌘R).

---

## Features overview

The app starts on **Rain SDK Demo**, where you initialize the SDK. After initialization, you can open each feature from the **SDK Features** list. Below is a short overview; each feature is explained in a collapsible section.

| Feature | Mode | Description |
|--------|------|-------------|
| **SDK Connection** | — | Initialize with Portal token or wallet-agnostic; configure Chain ID and RPC URL. |
| **Build EIP-712 Message** | Wallet-agnostic or Portal | Generate EIP-712 typed data for admin signatures. |
| **Build Withdraw Transaction** | Wallet-agnostic or Portal | Generate ABI-encoded withdraw calldata. |
| **Portal Withdraw** | Portal only | Full flow: access token → recover (optional) → withdraw (sign & submit). |

---

<details>
<summary><strong>SDK Connection (main screen)</strong></summary>

### What it does

- Lets you **initialize** the Rain SDK in one of two modes:
  - **Wallet-agnostic:** Network configs only (Chain ID + RPC URL). Use for building EIP-712 messages and withdraw calldata without a wallet.
  - **Portal:** Portal session token + network configs. Use for full flows (sign + submit via Portal).
- Shows **status** (ready / initialized / error) and any **error code** from the SDK.
- **Reinitialize** or **Reset SDK** after initialization.

### Inputs

- **Wallet-Agnostic Mode** (toggle): When on, no Portal token is required; when off, you must enter a Portal Session Token.
- **Portal Session Token** (if not wallet-agnostic): Token from your backend/Portal for the current session.
- **Chain ID**: e.g. `1` (Ethereum), `137` (Polygon), `43113` (Avalanche Fuji).
- **RPC URL**: JSON-RPC endpoint for the chain (e.g. Infura, Alchemy, public RPC).

### Flow

1. Set Wallet-Agnostic or enter Portal token.
2. Enter Chain ID and RPC URL.
3. Tap **Initialize SDK**.
4. When initialized, **SDK Features** list appears; you can open **Build EIP-712 Message**, **Build Withdraw Transaction**, or **Portal Withdraw** (Portal only).

</details>

---

<details>
<summary><strong>Build EIP-712 Message</strong></summary>

### What it does

- Calls the SDK’s `buildEIP712Message(chainId:walletAddress:assetAddresses:amount:decimals:nonce:)` to generate **EIP-712 typed data**.
- This message is what an admin (or Portal) signs to authorize a withdrawal. You can copy the JSON and salt (hex) for use in signing or other tools.

### Inputs

- **Chain ID**, **Wallet Address**, **Proxy Address**, **Token Address**, **Recipient Address**
- **Amount** (human-readable, e.g. `100`) and **Decimals** (e.g. `18`)
- **Nonce** (optional): Leave empty to let the SDK fetch from the contract.

### Result

- **EIP-712 message** (JSON string) and **Salt** (hex string). You can copy either to clipboard.

### When to use

- Wallet-agnostic: build the message and have an external signer produce the admin signature.
- With Portal: the same API is used internally before asking Portal to sign.

</details>

---

<details>
<summary><strong>Build Withdraw Transaction</strong></summary>

### What it does

- Calls the SDK’s `buildWithdrawTransactionData(chainId:assetAddresses:amount:decimals:expiresAt:salt:signatureData:adminSalt:adminSignature:)` to produce **ABI-encoded calldata** for the collateral proxy’s withdraw function.
- You supply user salt, user signature (from Rain API), admin salt, and admin signature; the SDK returns hex calldata (e.g. for `eth_sendTransaction` or custom submission).

### Inputs

- **Chain ID**, **Contract Address**, **Proxy Address**, **Token Address**, **Recipient Address**
- **Amount**, **Decimals**, **Expires At** (Unix timestamp string)
- **Salt** (user salt, base64 or hex), **Signature Data** (user signature, hex 65 bytes)
- **Admin Salt** and **Admin Signature** (from EIP-712 signing, 32 and 65 bytes)

### Result

- **Transaction data** (hex string starting with `0x`). Copy to use with `composeTransactionParameters` and your own submission path, or rely on **Portal Withdraw** to do build + sign + submit in one flow.

### When to use

- When you want to build the withdraw tx yourself and submit via another wallet or RPC.
- Helps validate that the SDK produces correct calldata for your contract and parameters.

</details>

---

<details>
<summary><strong>Portal Withdraw</strong></summary>

### What it does

- End-to-end **withdrawal via Portal**: you prove access with a **user access token**, optionally **recover** a wallet from backup, then run the **withdraw** screen where the app gets withdrawal signature from your API, builds the tx, has Portal sign it, and submits it.
- **Recipient address** is persisted in the sample app (e.g. UserDefaults) and reloaded when you open the flow again.

### Flow

1. **Entry (Portal Withdraw)**  
   - Enter **User Access Token** (your backend’s token for the user/session).  
   - Tap **Continue to Portal Withdraw**.  
   - The app verifies the token by loading credit contracts; on success it navigates to the withdraw screen with the selected contract/asset context.

2. **Recover Wallet (optional)**  
   - When the withdraw screen appears and the SDK has Portal, an alert may offer **Recover Wallet** (iCloud or Password).  
   - You can **Skip**, or choose **iCloud** or **Password** and recover from backup; backup data is fetched from your backend (e.g. `/v1/portal/backup`).

3. **Withdraw screen**  
   - **Asset** is chosen from the credit contract (with a reload button to refresh the list).  
   - **Recipient Address** is pre-filled from the last saved value.  
   - **Amount** and other fields are editable.  
   - Tap **Withdraw** to: get withdrawal signature from your API → build tx → Portal signs → submit.  
   - **Done** pops back to the root (Rain SDK Demo).

### Requirements

- SDK must be initialized **with Portal** (not wallet-agnostic).
- Backend: access token for entry, withdrawal signature API, and optionally backup API for recover.

</details>

---

<details>
<summary><strong>Recover Wallet (inside Portal Withdraw)</strong></summary>

### What it does

- Shown as an overlay when you open **Portal Withdraw** and the SDK has Portal.
- Lets the user **recover** a wallet from a backup (iCloud or password-protected). Backup ciphertext is loaded from your backend (e.g. `/v1/portal/backup`); the app uses Portal’s recover APIs with the chosen method.

### Options

- **iCloud**: Recover using iCloud-stored backup.
- **Password**: Recover using a backup protected by a password; user enters the password in the sheet.

### UX

- **Skip** closes the sheet without recovering.  
- After **Recover** or **Skip**, the user continues to the withdraw form.

</details>

---

## Project structure (high level)

```
RainSDKDemo/
├── RainSDKDemo.xcodeproj/
└── RainSDKDemo/                    # App source
    ├── RainSDKDemoApp.swift        # App entry
    ├── RainSDKDemo.entitlements
    ├── Assets.xcassets/
    ├── Core/
    │   ├── Network/                # APIClient, APIConfig, APIError, AuthTokenStorage
    │   └── Services/               # RainSDKService (wraps RainSDKManager)
    ├── Data/
    │   ├── Models/                 # AssetModel, CreditContractResponse, PortalBackupModels, etc.
    │   ├── Repositories/           # CreditContractsRepository, PortalBackupRepository, WithdrawalSignatureRepository
    │   └── Storage/                # AppStorage (e.g. saved recipient address)
    ├── Presentation/
    │   ├── ContentView.swift       # Root → SDKConnectionView
    │   ├── SDKConnectionView/      # Main screen (init, feature list)
    │   ├── BuildEIP712Message/     # EIP-712 message builder
    │   ├── BuildWithdrawTransaction/  # Withdraw calldata builder
    │   └── PortalWithdraw/         # Entry → Recover → Withdraw
    │       ├── PortalWithdrawEntry/
    │       ├── Recover/
    │       ├── PortalWithdrawDemoView.swift
    │       └── PortalWithdrawDemoViewModel.swift
    └── Utils/
        └── Extensions/             # e.g. hideKeyboard
```

---

## Configuration

- **API base URL** and **auth** (e.g. Bearer token) are typically set in `Core/Network/APIConfig.swift` and used by the demo’s repositories (credit contracts, withdrawal signature, backup). Point these at your backend.
- **Portal session token** and **user access token** are entered in the app; the demo may store the latter (e.g. in `AuthTokenStorage`) for convenience.

---

For the full list of SDK methods and parameters, see [Method overview](../../../docs/METHODS.md) in the repo docs.
