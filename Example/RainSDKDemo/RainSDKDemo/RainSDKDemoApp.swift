import SwiftUI

@main
struct RainSDKDemoApp: App {
  init() {
    // One-shot vendor init from the saved ids so a restored session can be resumed.
    // (Turnkey needs nothing here: the SDK's managed mode configures itself when the
    // provider is prepared during resume.)
    switch SessionStore.provider {
    case .privy where !SessionStore.privyAppId.isEmpty && !SessionStore.privyAppClientId.isEmpty:
      try? PrivyAuthSample.shared.initialize(
        appId: SessionStore.privyAppId,
        appClientId: SessionStore.privyAppClientId
      )
    default:
      break
    }
  }

  var body: some Scene {
    WindowGroup {
      HomeView()
    }
  }
}
