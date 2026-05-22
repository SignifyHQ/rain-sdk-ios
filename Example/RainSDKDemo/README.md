# Rain SDK Demo App

A SwiftUI sample app that demonstrates all public features of the **Rain SDK**. Use it to try SDK initialization, EIP-712 message building, withdraw transaction building, and full Portal withdrawal flows.

---

## Requirements

- Xcode 16+ (Swift 6.1)
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
| **SDK Connection** | — | Initialize with Portal token, Turnkey (passkey), or wallet-agnostic; configure Chain ID and RPC URL. |
| **Build EIP-712 Message** | Any mode | Generate EIP-712 typed data for admin signatures. |
| **Build Withdraw Transaction** | Any mode | Generate ABI-encoded withdraw calldata. |
| **Wallet Address & QR**, **Get Balances**, **Get Transactions**, **Transfer** | Portal or Turnkey | Wallet-bound features available with any wallet provider. |
| **Collateral Withdraw** | Portal or Turnkey | Full flow: access token → recover (Portal only) → withdraw (sign & submit). |

---

<details>
<summary><strong>SDK Connection (main screen)</strong></summary>

### What it does

- Lets you **initialize** the Rain SDK in one of three modes:
  - **Wallet-agnostic:** Network configs only (Chain ID + RPC URL). Use for building EIP-712 messages and withdraw calldata without a wallet.
  - **Portal:** Portal session token + network configs. Use for full flows (sign + submit via Portal).
  - **Turnkey:** Passkey (WebAuthn) login or sign-up. Once authenticated, the resulting `TurnkeyContext` is passed to Rain.
- Shows **status** (ready / initialized / error) and any **error code** from the SDK.
- **Reinitialize** or **Reset SDK** after initialization.

### Inputs

- **Wallet-Agnostic Mode** (toggle): When on, no provider config is required.
- **Wallet Provider** (when not wallet-agnostic): `Portal` or `Turnkey`.
- **Portal Session Token** (Portal only): Token from your backend/Portal for the current session.
- **Turnkey** (Turnkey only): Organization ID (your **parent** org id from Turnkey dashboard), API URL (defaults to `https://api.turnkey.com`), Auth Proxy URL (defaults to `https://authproxy.turnkey.com`), **Auth Proxy Config ID** (required for Sign Up), Relying Party ID (`rpId` — your Associated Domain). Tap **Sign Up with Passkey** the first time on a device (creates a sub-org + wallet + passkey), or **Login with Passkey** afterwards.
- **Chain ID** / **RPC URL**: defaults come from `DemoLocalConfig.swift` (e.g. Base Sepolia `84532` + `https://sepolia.base.org`). Edit that file for your network.
- **RPC URL**: JSON-RPC endpoint for the chain (e.g. Infura, Alchemy, public RPC).

### Flow

1. Pick a mode (wallet-agnostic, Portal, or Turnkey) and enter the relevant inputs.
2. Enter Chain ID and RPC URL.
3. Tap **Initialize SDK** (Portal/wallet-agnostic) or **Sign Up with Passkey** / **Login with Passkey** (Turnkey).
4. When initialized, the **SDK Features** list appears. With a wallet provider you also see **Wallet Address & QR**, **Get Balances**, **Get Transactions**, **Transfer**, and **Collateral Withdraw**.

</details>

---

<details>
<summary><strong>Turnkey provider (passkey)</strong></summary>

### What it does

- Lets you **Sign Up** (creates a Turnkey sub-org with a wallet and registers a passkey for this device) or **Login** (authenticates an existing passkey) via WebAuthn, then hands the authenticated `TurnkeyContext` to the Rain SDK so it can sign and submit transactions through Turnkey.
- Sub-org + wallet + passkey are all created in a single tap on signup — no Turnkey dashboard work required beyond creating the parent org account.
- Configuration values (parent org id, API URL, auth proxy URL, rpId) are read from `DemoLocalConfig.swift` on first launch, then persisted in `UserDefaults` (`TurnkeyConfigStorage`) once edited in the app. Edit `Example/RainSDKDemo/RainSDKDemo/DemoLocalConfig.swift` to set your local prefill values.

### Prerequisites — one-time Turnkey setup

You only need a parent Turnkey organization with an **Auth Proxy config** that's authorized to provision sub-orgs and wallets. The demo handles sub-org + wallet creation on signup.

1. **Sign up at [app.turnkey.com](https://app.turnkey.com)** (free).
2. From the dashboard, copy your **parent organization ID** — that's the `Organization ID` you'll paste into the demo.
3. Go to **Settings → Auth Proxy → Create config** (or open an existing config). Add your `rpId` (e.g. `abc123.ngrok-free.app`) to the config's allowed origins. Copy the **Auth Proxy Config ID** — that's what you paste into the demo's `Auth Proxy Config ID` field.
4. The default Auth Proxy URL `https://authproxy.turnkey.com` works for hosted Turnkey.

That's it — no need to manually create sub-orgs, wallets, or passkeys in the dashboard. The demo's **Sign Up with Passkey** provisions an Ethereum wallet at sub-org creation time by passing `customWallet` (`ADDRESS_FORMAT_ETHEREUM`, secp256k1, BIP32 path `m/44'/60'/0'/0/0`) in the signup request.

> **Why the client provides the wallet, not the auth proxy:** Turnkey's Auth Proxy config has no wallet template — it only configures allowed origins, email/SMS auth, and session length ([docs](https://docs.turnkey.com/reference/auth-proxy)). `proxySignupV2` creates a sub-org with **zero wallets** unless the signup request explicitly carries a wallet ([docs](https://docs.turnkey.com/api-reference/activities/create-sub-organization)). So the wallet shape is owned by the client. For a real production app you'd typically have your backend mint the sub-org via `CREATE_SUB_ORGANIZATION` directly (instead of the auth proxy) so the wallet shape is server-side.

### Inputs

- **Organization ID**: Your Turnkey **parent** org id (from dashboard).
- **API URL** / **Auth Proxy URL**: Default to Turnkey's hosted endpoints; override only if you run your own.
- **Auth Proxy Config ID**: The auth proxy config id from the Turnkey dashboard. Required for **Sign Up with Passkey**; optional for **Login with Passkey**.
- **Relying Party ID (`rpId`)**: The Associated Domain you've registered for your app. Must match an entry in your app's `webcredentials:` Associated Domains entitlement and an AASA file at `https://<rpId>/.well-known/apple-app-site-association`.

### Flow

1. Select **Turnkey** as the wallet provider and fill in the four config fields + chain id + RPC URL.
2. **First time on a device**: tap **Sign Up with Passkey**. The app calls `TurnkeyContext.shared.signUpWithPasskey(anchor:createSubOrgParams:)` with an Ethereum-wallet `customWallet`, which:
   - Creates a new sub-org under your parent org
   - Provisions an Ethereum wallet (`ADDRESS_FORMAT_ETHEREUM`, secp256k1, BIP32 path `m/44'/60'/0'/0/0`) inside that sub-org
   - Registers a new device passkey bound to your `rpId`
   - Returns an authenticated session
3. **Subsequent runs on the same device**: tap **Login with Passkey** — calls `TurnkeyContext.shared.loginWithPasskey(anchor:)` and re-uses the existing passkey + sub-org.
4. iOS shows the system passkey UI for both signup and login.
5. On success the app calls `RainSDKManager.initializeTurnkey(turnkey:networkConfigs:)` to bind the authenticated context to Rain.
6. All wallet-bound features (balances, transfers, withdraw) now work via Turnkey.

> **Note:** `TurnkeyContext.configure(...)` is a one-shot call for the process lifetime. If you change **Organization ID**, **API URL**, **Auth Proxy URL**, **Auth Proxy Config ID**, or **rpId** after the first passkey tap, the demo will surface a clear error on the next attempt — you must fully kill the app (swipe up in app switcher) and relaunch for the new values to take effect. **Reset SDK** does **not** clear this configuration.

### Requirements

- iOS 16+ for `ASAuthorizationPlatformPublicKeyCredentialProvider`-backed passkeys.
- An **Associated Domains** entitlement on the app: `webcredentials:<rpId>` — and a matching `apple-app-site-association` file served from `https://<rpId>/.well-known/apple-app-site-association`.
- For local testing without a public domain: see **[aasa/README.md](aasa/README.md)** for the full per-developer setup (one-time signing + AASA edits) and the per-session ngrok loop. That doc is the single source of truth for the passkey toolchain; this section just summarizes which inputs the app expects.

### Notes

- Auth and account/wallet provisioning are the host app's responsibility. This demo wires up passkey only; Turnkey also supports email OTP and OAuth, which you'd add in your own app. The Rain SDK only requires an authenticated `TurnkeyContext` whose user has at least one Ethereum wallet.
- Turnkey-backed wallets do not have a Portal-style backup/recovery flow, so the **Recover Wallet** sheet is not shown when running with Turnkey.
- If you see `RAIN_403 No wallet address available from the wallet provider` after **Login**, the sub-org you authenticated into has no Ethereum wallet. Easiest fix: tap **Sign Up with Passkey** instead — that creates a fresh sub-org with a wallet attached. The Turnkey Auth Proxy config has no wallet-template field, so the wallet shape has to be supplied client-side at signup (which this demo already does via `customWallet`).
- If you see `RAIN_501 Key already exists`, a previous session JWT is still in the Keychain under the default session key. The demo clears it explicitly before each login/signup; if it still happens, fully kill and relaunch the app.
- If you see `SIGNATURE_INVALID / credential ID could not be found` on **Login**, the passkey on this device was registered for a different `rpId` than the one in your config. Sign up again under the current `rpId`, or fix the rpId to match where the passkey was originally registered.

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
<summary><strong>Transfer</strong></summary>

### What it does

- Sends **native** or **ERC-20** tokens from the active wallet via the initialized provider (**Portal** or **Turnkey**).
- Same entry path for both providers: open **Transfer** directly from SDK Features after initialization — **no Rain API access token**.

### Flow

1. Initialize the SDK with **Portal** (session token) or **Turnkey** (passkey login/sign-up).
2. Open **Transfer** from the feature list.
3. Choose native or ERC-20, enter chain ID, recipient, amount (and token contract + decimals for ERC-20).
4. Optionally reload balances, then tap **Send**.

### Portal-only behavior

- When initialized with Portal, an optional **Recover Wallet** sheet appears on first open **only if a Rain API access token has already been saved** from a prior Collateral Withdraw visit (backup fetch requires it). Fresh Portal users and Turnkey users never see the sheet here.

### Requirements

- SDK initialized with a **wallet provider** (not wallet-agnostic).
- Chain ID and RPC URL from SDK Connection must match the network you transfer on.

</details>

---

<details>
<summary><strong>Collateral Withdraw</strong></summary>

### What it does

- End-to-end **collateral withdrawal**: you prove access with a **user access token**, optionally **recover** a wallet from backup (Portal only), then run the **withdraw** screen where the app gets the withdrawal signature from your API, builds the tx, has the active wallet provider (Portal or Turnkey) sign it, and submits it.
- **Recipient address** is persisted in the sample app (e.g. UserDefaults) and reloaded when you open the flow again.

### Flow

1. **Entry (Collateral Withdraw)**  
   - Enter **User Access Token** (your backend’s token for the user/session).  
   - Tap **Continue to Collateral Withdraw**.  
   - The app verifies the token by loading credit contracts; on success it navigates to the withdraw screen with the selected contract/asset context.

2. **Recover Wallet (optional)**  
   - When the withdraw screen appears and the SDK has Portal, an alert may offer **Recover Wallet** (iCloud or Password).  
   - You can **Skip**, or choose **iCloud** or **Password** and recover from backup; backup data is fetched from your backend (e.g. `/v1/portal/backup`).

3. **Withdraw screen**  
   - **Asset** is chosen from the credit contract (with a reload button to refresh the list).  
   - **Recipient Address** is pre-filled from the last saved value.  
   - **Amount** and other fields are editable.  
   - Tap **Withdraw** to: get withdrawal signature from your API → build tx → active wallet provider (Portal or Turnkey) signs → submit.  
   - **Done** pops back to the root (Rain SDK Demo).

### Requirements

- SDK must be initialized **with a wallet provider** (Portal or Turnkey, not wallet-agnostic).
- Backend: access token for entry, withdrawal signature API, and (Portal only) backup API for recover.

</details>

---

<details>
<summary><strong>Recover Wallet (inside Collateral Withdraw)</strong></summary>

### What it does

- Shown as an overlay when you open **Collateral Withdraw** and the SDK has Portal (not shown for Turnkey — Turnkey wallets don't have a Portal-style backup).
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
