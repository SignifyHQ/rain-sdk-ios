import Foundation

/// Central place for demo app UserDefaults. Add new keys to `Keys` and get/set helpers below as needed.
struct AppStorage {
  private static let store = UserDefaults.standard

  enum Keys {
    static let portalWithdrawRecipientAddress = "RainSDKDemo.PortalWithdraw.recipientAddress"
    // Add more keys here, e.g.:
    // static let lastSelectedChainId = "RainSDKDemo.lastSelectedChainId"
  }

  // MARK: - Portal Withdraw

  static func getPortalWithdrawRecipientAddress() -> String? {
    store.string(forKey: Keys.portalWithdrawRecipientAddress)
  }

  static func setPortalWithdrawRecipientAddress(_ value: String?) {
    if let value = value, !value.isEmpty {
      store.set(value, forKey: Keys.portalWithdrawRecipientAddress)
    }
  }
}
