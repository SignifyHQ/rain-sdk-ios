# FidesmoSupport

This package integrates Fidesmo SDK into the LiquidityFinancial app for contactless smart card operations.

## Features

- NFC Communication with Fidesmo cards
- Payment app installation and removal
- Card eligibility checks
- Secure service delivery

## Requirements

- iOS 15.0+
- Swift 5.7+
- Xcode 14.0+

## Dependencies

- [Fidesmo iOS SDK](https://github.com/fidesmo/fidesmo-ios-sdk)
- [RxSwift](https://github.com/ReactiveX/RxSwift)

## Configuration

To use this package, ensure the host app has:

1. NFC Capability added to the project
2. Proper entitlements:
   - com.apple.developer.nfc.readersession.formats
   - com.apple.developer.associated-domains

3. Info.plist configurations:
   - NFCReaderUsageDescription
   - com.apple.developer.nfc.readersession.iso7816.select-identifiers
   - CFBundleURLTypes for Fidesmo URL scheme

## Usage

```swift
import FidesmoSupport

// Initialize your NFC manager
let nfcManager = FidesmoSupport.createNFCManager(delegate: self)

// Start NFC discovery
nfcManager.startNfcDiscovery(message: "Hold your iPhone near a Fidesmo card")
``` 