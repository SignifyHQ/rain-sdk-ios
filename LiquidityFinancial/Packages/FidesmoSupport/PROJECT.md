# Fidesmo Integration Guide

## Integration Steps

1. Add the FidesmoSupport package to your project dependencies

```swift
// In your project's Package.swift or directly in Xcode
dependencies: [
    .package(path: "../Packages/FidesmoSupport")
],
```

2. Ensure NFC capabilities are enabled in your project settings

- Go to Target > Signing & Capabilities
- Add the Near Field Communication Tag Reading capability
- Add the Associated Domains capability

3. Update your app's entitlements file to include:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:apps.fidesmo.com</string>
    <string>applinks:apps-staging.fidesmo.com?mode=developer</string>
</array>

<key>com.apple.developer.nfc.readersession.formats</key>
<array>
    <string>TAG</string>
</array>
```

4. Update your Info.plist to include:

```xml
<!-- NFC Reader usage description -->
<key>NFCReaderUsageDescription</key>
<string>This app uses NFC to interact with your Fidesmo smart card for secure payment services.</string>

<!-- NFC Tag-ISO7816 App IDs -->
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
    <string>A000000151000000</string>
    <!-- Add all required Fidesmo identifiers -->
</array>

<!-- URL Scheme for Fidesmo deep links -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.fidesmo.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>fidesmo</string>
        </array>
    </dict>
</array>
```

5. Import and use in your view models or services:

```swift
import FidesmoSupport

class YourViewModel {
    private let nfcManager = FidesmoSupport.createNFCManager(delegate: self)
    
    func startNfcScanning() {
        nfcManager.startNfcDiscovery(message: "Hold your iPhone near a Fidesmo card")
    }
}
```

## Testing

For testing, you'll need an actual Fidesmo card. Simulators do not support NFC.

## Troubleshooting

- If you're encountering "Missing NFC Reader Session" errors, check that your entitlements and Info.plist are correctly configured.
- Verify that your device supports NFC (iPhone 6S and above).
- Make sure your app has the necessary permissions to use NFC in your development provisioning profile. 