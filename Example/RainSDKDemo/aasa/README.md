# Local AASA setup for passkey testing

iOS passkeys (WebAuthn) require an **Associated Domain** — a hostname iOS can fetch an `apple-app-site-association` (AASA) file from. This folder lets you serve one locally so the demo's Turnkey passkey flow works on a simulator without a public domain.

## How it works

iOS validates passkeys by comparing two strings, both on your Mac, no Apple servers involved:

1. The `<TeamID>.<BundleID>` baked into your build's signed `application-identifier` entitlement.
2. The `apps` array in the AASA your `rpId` host returns.

If they match, AASA validation passes and the passkey UI works. So the per-developer setup is just: make those two match, on a hostname your simulator can reach over HTTPS.

## Files in this folder

- `.well-known/apple-app-site-association` — the JSON iOS fetches. The `apps` array lists every `<TeamID>.<BundleID>` allowed to use this rpId. Devs append their own line.
- `serve.py` — minimal HTTP server that returns the file with `Content-Type: application/json` (which iOS requires).

## One-time setup (per developer)

### 1. Pick your Xcode team
Open `RainSDKDemo.xcodeproj` → **RainSDKDemo** target → **Signing & Capabilities**. Sign in with any Apple ID (free Personal Team works for simulator). Xcode shows the **10-character Team ID** in the same panel after the first build.

### 2. Leave the bundle id as `com.rain.sdk`

### 3. Add your `<TeamID>.com.rain.sdk` to the AASA
Edit `.well-known/apple-app-site-association` and append your entry:

```json
{
  "webcredentials": {
    "apps": [
      "FZH8UTZ72Q.com.rain.sdk",
      "YOURTEAMID.com.rain.sdk"
    ]
  }
}
```

iOS scans the array; any match works. Append, don't replace, so the file works for everyone.

### 4. Fill in `DemoLocalConfig.swift`
Edit `Example/RainSDKDemo/RainSDKDemo/DemoLocalConfig.swift` with your Turnkey org id, auth proxy config id, and the rpId you'll use (your ngrok hostname). These prefill the SDK Connection screen on each launch.

To keep your edits out of git:
```bash
git update-index --skip-worktree Example/RainSDKDemo/RainSDKDemo/DemoLocalConfig.swift
```

## Each session

The ngrok hostname rotates each time on free ngrok, so this loop runs every session:

```bash
# Terminal A — serve the AASA
python3 Example/RainSDKDemo/aasa/serve.py

# Terminal B — tunnel it over HTTPS
ngrok http 8080
```

Copy the `https://<random>.ngrok-free.app` URL. Hostname only (no scheme, no path) is your **rpId**. Then:

1. **Verify the AASA is reachable** (optional but useful):
   ```bash
   curl -i https://<random>.ngrok-free.app/.well-known/apple-app-site-association
   ```
   Expect HTTP 200 + JSON body + `Content-Type: application/json`.

2. **Update two places with the new hostname:**
   - `RainSDKDemo.entitlements` → `webcredentials:<host>` line
   - `DemoLocalConfig.swift` → `turnkeyRpId`

3. **Delete the app on the simulator** (long-press → Remove App). iOS only validates Associated Domains on a fresh install.

4. **⌘R** in Xcode to build and reinstall. Tap **Sign Up with Passkey** (first time on this rpId) or **Login with Passkey** (subsequent).

## Notes

- Free ngrok rotates hostnames every session — paid ngrok or a free Vercel deploy gives a stable hostname so steps 2–4 stop repeating.
- Apple's CDN caches AASA aggressively. Deleting + reinstalling the app forces a refetch.
