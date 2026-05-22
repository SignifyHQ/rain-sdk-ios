import Foundation

/// Central place for demo app UserDefaults. Add new keys to `Keys` and get/set helpers below as needed.
struct AppStorage {
  private static let store = UserDefaults.standard

  enum Keys {
    static let collateralWithdrawRecipientAddress = "RainSDKDemo.CollateralWithdraw.recipientAddress"
    // Add more keys here, e.g.:
    // static let lastSelectedChainId = "RainSDKDemo.lastSelectedChainId"
  }

  // MARK: - Collateral Withdraw

  static func getCollateralWithdrawRecipientAddress() -> String? {
    store.string(forKey: Keys.collateralWithdrawRecipientAddress)
  }

  static func setCollateralWithdrawRecipientAddress(_ value: String?) {
    if let value = value, !value.isEmpty {
      store.set(value, forKey: Keys.collateralWithdrawRecipientAddress)
    }
  }
}
